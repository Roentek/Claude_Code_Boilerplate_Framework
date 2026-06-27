#!/usr/bin/env node
/**
 * FFmpeg video/audio processing tool
 * Commands: probe, transcode, trim, thumbnail, extract-audio, concat
 * All output is JSON to stdout; errors to stderr with exit code 1.
 *
 * Usage:
 *   node tools/ffmpeg.js probe <input>
 *   node tools/ffmpeg.js transcode <input> [output] [--format mp4|webm|mov] [--quality <crf>] [--resolution WxH] [--fps <n>]
 *   node tools/ffmpeg.js trim <input> [output] [--start <time>] [--end <time>] [--duration <secs>]
 *   node tools/ffmpeg.js thumbnail <input> [output] [--at <time>] [--width <px>]
 *   node tools/ffmpeg.js extract-audio <input> [output] [--format mp3|wav|aac|flac] [--bitrate <kbps>]
 *   node tools/ffmpeg.js concat <file1> <file2> ... [--output <out>]
 *
 * Time format: HH:MM:SS or seconds (e.g. 00:01:30 or 90)
 */
import { spawnSync } from 'child_process';
import { mkdirSync, writeFileSync } from 'fs';
import { resolve, extname, basename, dirname } from 'path';

const [,, cmd, ...rawArgs] = process.argv;

if (!cmd) {
  console.error(JSON.stringify({ error: 'No command. Use: probe, transcode, trim, thumbnail, extract-audio, concat' }));
  process.exit(1);
}

function parseArgs(args) {
  const flags = {};
  const positional = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i].startsWith('--')) {
      const key = args[i].slice(2);
      flags[key] = args[i + 1] !== undefined && !args[i + 1].startsWith('--') ? args[++i] : true;
    } else {
      positional.push(args[i]);
    }
  }
  return { flags, positional };
}

function ffmpeg(args) {
  const r = spawnSync('ffmpeg', args, { encoding: 'utf8' });
  if (r.status !== 0) throw new Error(r.stderr?.split('\n').slice(-5).join('\n') || `ffmpeg exited ${r.status}`);
}

function ffprobe(args) {
  const r = spawnSync('ffprobe', args, { encoding: 'utf8' });
  if (r.status !== 0) throw new Error(r.stderr?.split('\n').slice(-3).join('\n') || `ffprobe exited ${r.status}`);
  return r.stdout;
}

function sibling(input, suffix, ext) {
  return resolve(dirname(input), `${basename(input, extname(input))}${suffix}${ext}`);
}

function parseFps(rateStr) {
  const [n, d] = (rateStr || '0/1').split('/').map(Number);
  return d ? Math.round((n / d) * 100) / 100 : n;
}

const { flags, positional } = parseArgs(rawArgs);

try {
  switch (cmd) {
    case 'probe': {
      const [input] = positional;
      if (!input) throw new Error('Input required: node tools/ffmpeg.js probe <input>');
      const raw = ffprobe(['-v', 'quiet', '-print_format', 'json', '-show_format', '-show_streams', resolve(input)]);
      const d = JSON.parse(raw);
      const fmt = d.format || {};
      const vid = d.streams?.find(s => s.codec_type === 'video');
      const aud = d.streams?.find(s => s.codec_type === 'audio');
      console.log(JSON.stringify({
        duration_secs: parseFloat(fmt.duration || 0),
        size_bytes: parseInt(fmt.size || 0),
        bitrate_kbps: Math.round(parseInt(fmt.bit_rate || 0) / 1000),
        format: fmt.format_name,
        video: vid ? {
          codec: vid.codec_name,
          width: vid.width,
          height: vid.height,
          fps: parseFps(vid.r_frame_rate),
          bitrate_kbps: Math.round(parseInt(vid.bit_rate || 0) / 1000),
        } : null,
        audio: aud ? {
          codec: aud.codec_name,
          sample_rate: parseInt(aud.sample_rate),
          channels: aud.channels,
          bitrate_kbps: Math.round(parseInt(aud.bit_rate || 0) / 1000),
        } : null,
      }, null, 2));
      break;
    }

    case 'transcode': {
      const [input, output] = positional;
      if (!input) throw new Error('Input required: node tools/ffmpeg.js transcode <input> [output]');
      const fmt = flags.format || 'mp4';
      const out = resolve(output || sibling(input, '_transcoded', `.${fmt}`));
      const args = ['-i', resolve(input)];
      if (flags.resolution) args.push('-vf', `scale=${flags.resolution}`);
      if (flags.fps) args.push('-r', flags.fps);
      args.push('-crf', flags.quality || '23', '-preset', 'fast', '-y', out);
      ffmpeg(args);
      console.log(JSON.stringify({ success: true, path: out }));
      break;
    }

    case 'trim': {
      const [input, output] = positional;
      if (!input) throw new Error('Input required: node tools/ffmpeg.js trim <input> [output] [--start <time>] [--end <time>]');
      const out = resolve(output || sibling(input, '_trimmed', extname(input)));
      const args = ['-i', resolve(input)];
      if (flags.start) args.push('-ss', flags.start);
      if (flags.end) args.push('-to', flags.end);
      if (flags.duration) args.push('-t', flags.duration);
      args.push('-c', 'copy', '-y', out);
      ffmpeg(args);
      console.log(JSON.stringify({ success: true, path: out }));
      break;
    }

    case 'thumbnail': {
      const [input, output] = positional;
      if (!input) throw new Error('Input required: node tools/ffmpeg.js thumbnail <input> [output]');
      const out = resolve(output || sibling(input, '_thumb', '.jpg'));
      const args = ['-i', resolve(input), '-ss', flags.at || '00:00:10', '-vframes', '1'];
      if (flags.width) args.push('-vf', `scale=${flags.width}:-1`);
      args.push('-y', out);
      ffmpeg(args);
      console.log(JSON.stringify({ success: true, path: out }));
      break;
    }

    case 'extract-audio': {
      const [input, output] = positional;
      if (!input) throw new Error('Input required: node tools/ffmpeg.js extract-audio <input> [output]');
      const fmt = flags.format || 'mp3';
      const out = resolve(output || sibling(input, '_audio', `.${fmt}`));
      const args = ['-i', resolve(input), '-vn'];
      if (flags.bitrate) args.push('-ab', `${flags.bitrate}k`);
      args.push('-y', out);
      ffmpeg(args);
      console.log(JSON.stringify({ success: true, path: out }));
      break;
    }

    case 'concat': {
      if (positional.length < 2) throw new Error('At least 2 inputs required: node tools/ffmpeg.js concat <file1> <file2> ... [--output <out>]');
      const out = resolve(flags.output || '.tmp/concat_output.mp4');
      const listPath = resolve('.tmp/ffmpeg_concat_list.txt');
      mkdirSync(resolve('.tmp'), { recursive: true });
      writeFileSync(listPath, positional.map(f => `file '${resolve(f)}'`).join('\n'));
      ffmpeg(['-f', 'concat', '-safe', '0', '-i', listPath, '-c', 'copy', '-y', out]);
      console.log(JSON.stringify({ success: true, path: out }));
      break;
    }

    default:
      throw new Error(`Unknown command: "${cmd}". Available: probe, transcode, trim, thumbnail, extract-audio, concat`);
  }
} catch (err) {
  console.error(JSON.stringify({ error: err.message }));
  process.exit(1);
}
