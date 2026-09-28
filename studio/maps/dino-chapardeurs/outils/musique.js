#!/usr/bin/env node
/* « Symphonie de la jungle » : pièce pour piano composée pour Dino Chapardeurs (do majeur, 76 bpm).
   Ce script écrit la partition une seule fois et en tire :
     - src/ReplicatedStorage/Dino/Partition.lua : la partition jouée note à note par Interface/Musique ;
     - musique/symphonie-piano.wav : l'enregistrement complet (piano de synthèse + réverbération),
       à téléverser sur Roblox (Creator Hub > Audio) puis à déclarer dans Interface/Musique (MUSIQUE_ID) ;
     - musique/note-piano-do4.wav : un seul do4 de piano, pour que la partition soit jouée avec un vrai
       timbre de piano (NOTE_PIANO_ID) si on préfère ne pas téléverser l'enregistrement complet.
   Usage : node outils/musique.js                                                                     */
"use strict";
const fs = require("fs");
const path = require("path");

const PROJET = path.resolve(__dirname, "..");
const BPM = 76;
const TAUX = 44100;

// ===== la composition =====
const NOTE = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
const midi = n => { const m = /^([A-G])(#|b)?(\d)$/.exec(n); return 12 * (+m[3] + 1) + NOTE[m[1]] + (m[2] === "#" ? 1 : m[2] === "b" ? -1 : 0); };
// accords : fondamentale (grave), tierce (3 = mineure, 4 = majeure), basse éventuelle, septième
const ACCORDS = {
  C: { r: "C3", t: 4 }, "G/B": { r: "G2", t: 4, basse: "B2" }, Am: { r: "A2", t: 3 }, F: { r: "F2", t: 4 },
  G: { r: "G2", t: 4 }, Em: { r: "E3", t: 3 }, Dm: { r: "D3", t: 3 }, G7: { r: "G2", t: 4, sept: true },
};
// mélodie : [note, durée en temps] ; « - » = silence
const A = [
  ["C", [["E5", 1], ["G5", 1], ["E5", .5], ["D5", .5], ["C5", 1]]],
  ["G/B", [["D5", 1.5], ["E5", .5], ["D5", 1], ["B4", 1]]],
  ["Am", [["C5", 1], ["E5", 1], ["A5", 1.5], ["G5", .5]]],
  ["F", [["F5", 1], ["E5", .5], ["D5", .5], ["C5", 2]]],
  ["C", [["E5", 1], ["G5", 1], ["C6", 1.5], ["B5", .5]]],
  ["F", [["A5", 1], ["G5", .5], ["F5", .5], ["E5", 1], ["D5", 1]]],
  ["G", [["D5", 1], ["E5", .5], ["F5", .5], ["G5", 1], ["B4", 1]]],
  ["C", [["C5", 3], ["G4", 1]]],
];
const B = [
  ["Am", [["A4", 1], ["C5", 1], ["E5", 1], ["D5", .5], ["C5", .5]]],
  ["F", [["A4", 1.5], ["C5", .5], ["F5", 2]]],
  ["C", [["G5", 1], ["E5", 1], ["C5", 1], ["E5", 1]]],
  ["G", [["D5", 2], ["B4", 1], ["G4", 1]]],
  ["Am", [["A5", 1], ["G5", .5], ["E5", .5], ["A5", 1], ["B5", 1]]],
  ["F", [["C6", 1.5], ["A5", .5], ["F5", 2]]],
  ["C", [["E5", 1], ["G5", 1], ["C6", 1], ["B5", .5], ["A5", .5]]],
  ["G", [["G5", 2], ["D5", 1], ["B4", 1]]],
];
const PONT = [
  ["F", [["A5", 2], ["C6", 1], ["A5", 1]]],
  ["G", [["B5", 2], ["D6", 1], ["B5", 1]]],
  ["Em", [["G5", 1.5], ["E5", .5], ["B4", 2]]],
  ["Am", [["C5", 1], ["E5", 1], ["A5", 2]]],
  ["Dm", [["F5", 1], ["A5", 1], ["D6", 1], ["C6", .5], ["A5", .5]]],
  ["G", [["B5", 1], ["G5", 1], ["D5", 1], ["F5", 1]]],
  ["C", [["E5", 1], ["G5", 1], ["C6", 2]]],
  ["G7", [["D6", 1], ["B5", 1], ["G5", 1], ["F5", 1]]],
];
const INTRO = [["C", [["-", 4]]], ["G/B", [["-", 4]]]];
// A' : la mélodie doublée à l'octave sur les temps forts
const A2 = A.map(([ch, mel]) => [ch, mel, true]);
const FORME = [...INTRO, ...A, ...B, ...PONT, ...A2];

const notes = []; // { t (temps), d (temps), m (midi), v (0..1) }
let temps = 0;
FORME.forEach(([nomAccord, melodie, doublee], mesure) => {
  const ch = ACCORDS[nomAccord];
  const r = midi(ch.r);
  // basse tenue
  const basse = ch.basse ? midi(ch.basse) : r;
  notes.push({ t: temps, d: 4, m: basse - 12 >= 28 ? basse - 12 : basse, v: 0.32 });
  // arpège de la main gauche en croches (motif montant-descendant)
  const third = ch.t, top = ch.sept ? 10 : 12;
  const motif = [0, 7, 12, 12 + third, 12 + 7, 12 + third, top, 7];
  motif.forEach((iv, k) => notes.push({ t: temps + k * 0.5, d: 0.9, m: r + iv, v: k === 0 ? 0.3 : 0.22 }));
  // main droite
  let t = temps;
  melodie.forEach(([n, d], k) => {
    if (n !== "-") {
      const m = midi(n);
      const fort = t === temps || t === temps + 2;
      notes.push({ t, d, m, v: fort ? 0.62 : 0.52 });
      if (doublee && fort) notes.push({ t, d, m: m + 12, v: 0.3 });
    }
    t += d;
  });
  temps += 4;
});
// accord final (fin de boucle douce) : rien, la boucle repart sur l'intro
const DUREE_TEMPS = temps;
notes.sort((a, b) => a.t - b.t || a.m - b.m);

// ===== 1. Partition.lua =====
const lua = [
  "-- Partition de la « Symphonie de la jungle » (généré par outils/musique.js : ne pas modifier à la main).",
  "-- Chaque note : { temps (en battements), durée (battements), hauteur MIDI (60 = do4), vélocité 0..1 }.",
  "return {",
  `\ttitre = "Symphonie de la jungle",`,
  `\tbpm = ${BPM},`,
  `\tduree = ${DUREE_TEMPS}, -- battements (la boucle recommence ensuite)`,
  "\tnotes = {",
  ...notes.map(n => `\t\t{ ${+n.t.toFixed(3)}, ${+n.d.toFixed(3)}, ${n.m}, ${+n.v.toFixed(2)} },`),
  "\t},",
  "}",
  "",
].join("\n");
fs.writeFileSync(path.join(PROJET, "src", "ReplicatedStorage", "Dino", "Partition.lua"), lua);

// ===== 2. synthèse de piano =====
const freq = m => 440 * Math.pow(2, (m - 69) / 12);
function notePiano(buf, debut, m, vel, dureeS) {
  const f0 = freq(m);
  const longueur = Math.min(buf.length - debut, Math.floor(TAUX * (dureeS + 2.2)));
  const B = 0.0004 * Math.pow(2, (m - 60) / 24); // légère inharmonicité des cordes
  const partiels = [];
  for (let k = 1; k <= 12; k++) {
    const fk = f0 * k * Math.sqrt(1 + B * k * k);
    if (fk > TAUX / 2.2) break;
    const amp = vel * Math.pow(k, -1.15) * (k === 1 ? 1 : 0.9) * (1 + 0.25 * Math.sin(k * 1.7));
    const decl = (0.55 + 0.12 * k) * (1 + (m - 60) / 60); // les aigus et les harmoniques s'éteignent plus vite
    partiels.push([fk, amp, decl, Math.random() * Math.PI * 2]);
  }
  const relache = debut + Math.floor(TAUX * dureeS); // étouffoir
  for (let i = 0; i < longueur; i++) {
    const t = i / TAUX;
    let s = 0;
    for (const [fk, amp, decl, ph] of partiels) s += amp * Math.exp(-decl * t) * Math.sin(2 * Math.PI * fk * t + ph);
    const attaque = Math.min(1, t / 0.004);
    let env = attaque;
    if (debut + i > relache) env *= Math.exp(-(debut + i - relache) / (TAUX * 0.35));
    // petit bruit de marteau
    if (t < 0.012) s += vel * 0.25 * (Math.random() * 2 - 1) * (1 - t / 0.012);
    buf[debut + i] += s * env * 0.22;
  }
}
function reverb(entree) {
  // réverbération de Schroeder : 4 filtres en peigne + 2 passe-tout
  const sortie = new Float32Array(entree.length);
  const peignes = [1557, 1617, 1491, 1422].map(d => ({ d, buf: new Float32Array(d), i: 0, g: 0.8 }));
  const passes = [225, 556].map(d => ({ d, buf: new Float32Array(d), i: 0, g: 0.5 }));
  for (let n = 0; n < entree.length; n++) {
    const x = entree[n];
    let s = 0;
    for (const c of peignes) { const y = c.buf[c.i]; c.buf[c.i] = x + y * c.g; c.i = (c.i + 1) % c.d; s += y; }
    s /= 4;
    for (const a of passes) { const y = a.buf[a.i]; const v = s + y * a.g; a.buf[a.i] = v; a.i = (a.i + 1) % a.d; s = y - v * a.g; }
    sortie[n] = x * 0.82 + s * 0.35;
  }
  return sortie;
}
function ecrireWav(fichier, donnees) {
  let max = 0;
  for (const v of donnees) max = Math.max(max, Math.abs(v));
  const gain = max > 0 ? 0.89 / max : 1;
  const tampon = Buffer.alloc(44 + donnees.length * 2);
  tampon.write("RIFF", 0); tampon.writeUInt32LE(36 + donnees.length * 2, 4); tampon.write("WAVE", 8);
  tampon.write("fmt ", 12); tampon.writeUInt32LE(16, 16); tampon.writeUInt16LE(1, 20); tampon.writeUInt16LE(1, 22);
  tampon.writeUInt32LE(TAUX, 24); tampon.writeUInt32LE(TAUX * 2, 28); tampon.writeUInt16LE(2, 32); tampon.writeUInt16LE(16, 34);
  tampon.write("data", 36); tampon.writeUInt32LE(donnees.length * 2, 40);
  for (let i = 0; i < donnees.length; i++) tampon.writeInt16LE(Math.max(-32767, Math.min(32767, Math.round(donnees[i] * gain * 32767))), 44 + i * 2);
  fs.mkdirSync(path.dirname(fichier), { recursive: true });
  fs.writeFileSync(fichier, tampon);
}

const secParTemps = 60 / BPM;
const dureeS = DUREE_TEMPS * secParTemps;
// on rend une boucle et demie pour que la queue de réverbération de la fin retombe sur le début
const piste = new Float32Array(Math.ceil(TAUX * (dureeS + 3)));
for (const n of notes) notePiano(piste, Math.floor(n.t * secParTemps * TAUX), n.m, n.v, n.d * secParTemps);
const boucle = reverb(piste);
// repli de la queue sur le début : la boucle s'enchaîne sans coupure
const finale = boucle.slice(0, Math.ceil(TAUX * dureeS));
for (let i = finale.length; i < boucle.length; i++) finale[i - finale.length] += boucle[i];
ecrireWav(path.join(PROJET, "musique", "symphonie-piano.wav"), finale);

const note = new Float32Array(TAUX * 4);
notePiano(note, 0, 60, 0.7, 2.5);
ecrireWav(path.join(PROJET, "musique", "note-piano-do4.wav"), reverb(note));

console.log(`✔ Symphonie de la jungle : ${notes.length} notes, ${FORME.length} mesures, ${dureeS.toFixed(1)} s (boucle)`);
console.log("✔ src/ReplicatedStorage/Dino/Partition.lua, musique/symphonie-piano.wav, musique/note-piano-do4.wav");
