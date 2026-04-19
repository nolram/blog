---
title: "Equipment"
date: 2026-04-18T20:44:59-03:00
draft: false
description: "A complete overview of my astrophotography setup for deep sky, planetary and timelapse work — from the telescope to the controller."
tags: ["setup", "equipment", "deep sky", "planetary", "guiding"]
categories: ["astrophotography"]
equipment:
  telescope: "ASKAR FRA400 / Newtonian 150mm f/5"
  camera: "ZWO ASI533MC Pro / ZWO ASI662MC / ZWO ASI120 (guide)"
  mount: "EQ-5 with OnStep"
  filters:
    - "Optolong L-Pro"
    - "Optolong L-eXtreme"
    - "CLS"
    - "UHC"
    - "IR/UV Cut"
    - "Moon Filter"
capture:
  date: ""
  location: ""
  frames: 0
  exposure: ""
  total_integration: ""
  bortle: 0
cover:
  image: "cover.webp"
  alt: "Astrophotography setup under the southern hemisphere sky"
---

Building an astrophotography setup is a gradual process — every piece chosen has a specific role, and the whole system needs to work in harmony. In this post I present the equipment that makes up my current setup, used both in fixed sessions in Porto Alegre and on expeditions to darker skies like Cambará do Sul.

---

## Telescopes

### ASKAR FRA400 — Apochromatic Refractor

The FRA400 is my main telescope for deep sky work. It's a high-quality apochromatic refractor that is compact and quick to set up — essential traits for portable sessions. With the 0.7x focal reducer, I widen the field and lower the focal ratio, making it even more efficient for emission objects like narrowband nebulae. It's the ideal partner for capturing the Carina Nebula, supernova remnants and mid-sized galaxies.

**Key specs:**
- Apochromatic refractor with excellent chromatic correction
- Portable and quick to deploy
- Compatible with 0.7x focal reducer
- Ideal for narrowband nebulae and galaxies

![ASKAR FRA400 with camera attached](askar_and_canon_v1.webp)

![ASKAR FRA400](askar_v1.webp)

---

### Newtonian 150mm / f5 (750mm)

The 150mm aperture, 750mm focal length Newtonian is my highest light-gathering and resolution instrument. It's used both for high-resolution planetary astrophotography — Jupiter, Saturn and the Moon — and for intermediate deep sky work. Being a reflector, it requires periodic collimation, which I perform with a laser collimator and a dedicated camera to ensure maximum sharpness.

**Key specs:**
- Aperture: 150mm / Focal length: 750mm
- High resolution for planetary work
- Greater light-gathering power for diffuse objects
- Requires regular collimation

![Newtonian 150mm](newtonian_v2.webp)

![Newtonian prepared for solar observation](newtonian_solar_v1.webp)

---

## Mount — EQ-5 with OnStep

The motorized EQ-5 equatorial mount, upgraded with the **OnStep** system, is the heart of the setup. OnStep is an open-source control solution that turns mechanical mounts into platforms capable of high-precision tracking, goto and autoguiding integration.

The motorization was sourced through **[OnStep Brasil](https://www.instagram.com/onstepbrasiloficial/)**, a Brazilian project offering pre-configured motorization kits and an installation service — an excellent option for anyone wanting to upgrade their mount without dealing with electronics from scratch. The kit is available from [Fóton Astro](https://fotonastro.com.br/produto/motorizacao-onstep-e-servico-de-instalacao/), with Portuguese-language support and shipping across Brazil.

The mount is controlled by the **ASIAIR Plus**, which centralizes all session management — from polar alignment to automated capture sequences.

**Capabilities:**
- Precise tracking in RA and DEC
- Autoguiding support
- Control via ASIAIR Plus
- Compatible with long exposures (>5 minutes per frame)

---

## Cameras

### ZWO ASI533MC Pro — Deep Sky

The ASI533MC Pro is my main camera for deep-field astrophotography. It's a cooled color CMOS with an 11.1MP square sensor that eliminates vignetting in the corners and delivers excellent signal-to-noise ratio even in long exposures. The active cooling system significantly reduces thermal noise, allowing multi-hour sessions with consistent quality.

**Key specs:**
- Sony IMX533 CMOS sensor, 11.1MP (3008×3008px)
- Active cooling (up to -35°C below ambient temperature)
- Compatible with narrowband filters (L-eXtreme)
- Low read noise and high well depth

---

### ZWO ASI662MC — Planetary

For planetary astrophotography, speed is everything. The ASI662MC is a high frame-rate camera, allowing hundreds of frames per second to be captured during the best moments of atmospheric seeing. The result is short videos that, after processing with software like AutoStakkert!, reveal fine details in Jupiter's cloud bands, Saturn's rings and lunar craters.

**Key specs:**
- High frame rate (ideal for Lucky Imaging)
- Sensitive, low-noise sensor
- Used with the Newtonian 150mm
- Video capture for subsequent stacking

---

### ZWO ASI120 — Guide Camera

The ASI120 is dedicated exclusively to autoguiding. Attached to a guide scope, it monitors mount behavior in real time and sends corrections to the OnStep via the ASIAIR Plus. A guiding performance below **1.5 arcsec RMS** is my goal for achieving pinpoint stars in long exposures.

**Role:** Active autoguiding via ASIAIR Plus (RA and DEC)

---

### GoPro Hero 12 Black — Timelapse

For astronomical timelapses and environmental field documentation, I use the GoPro Hero 12 Black. With manual control of shutter speed, ISO and frame interval, it produces impressive sequences of the sky's apparent motion — including moonrises and moonsets. It's my portable documentation tool for expeditions.

---

### Samsung Galaxy S24 Ultra + DJI Osmo Mobile 6 — Mobile Timelapse

Alongside the GoPro, I use the **Samsung Galaxy S24 Ultra** for night timelapses on a tripod. The S24 Ultra's camera offers excellent low-light sensitivity and advanced manual control of exposure, shutter and ISO — enough to capture star trails impressively straight from a smartphone.

For maximum stability and to eliminate any vibration during captures, the phone is attached to the **DJI Osmo Mobile 6**, a 3-axis gimbal that, even in static tripod mode, provides a rigid and balanced platform. The combination of the S24 Ultra and the Osmo Mobile 6 is a lightweight, quick-to-set-up rig that is surprisingly capable for documenting field sessions.

---

## Controller — ASIAIR Plus

The **ASIAIR Plus** is the central hub of the entire setup. It connects and controls cameras, mount, focuser and filters from a single app on a tablet or smartphone. The features I use most include automatic plate solving (for precise object centering), assisted polar alignment and dithering — an essential technique for eliminating noise patterns in long sessions.

**Key features:**
- ZWO camera control
- Mount control via OnStep
- Plate solving and automated goto
- Polar alignment (SharpCap-style)
- Integrated autoguiding
- Dithering between sub-exposures
- Automated sequences

---

## Filters

Choosing the right filter can completely transform an image, especially under urban skies with moderate light pollution.

| Filter | Primary use |
|---|---|
| **Optolong L-Pro** | Broadband deep sky, light pollution reduction |
| **Optolong L-eXtreme** | Narrowband (Hα + OIII), emission nebulae |
| **CLS** | General light pollution reduction |
| **UHC** | Emission and planetary nebulae |
| **IR/UV Cut** | Protection and sharpness for cameras without AA filter |
| **Moon Filter** | Lunar brightness reduction for observation and photography |

The **L-eXtreme** is by far the filter I use most in deep sky sessions with the ASI533MC Pro — it isolates hydrogen-alpha and oxygen-III emissions efficiently, allowing fine nebula detail to be captured even from Porto Alegre.

---

## Where to Buy — Recommended Store

Most of my equipment was purchased from **[Fóton Astro](https://fotonastro.com.br)**, which I consider the national reference for astronomical equipment. Fóton Astro is Brazil's largest telescope and astronomical equipment store, with nationwide shipping, a 1-year warranty and a complete catalog ranging from telescopes and mounts to ZWO cameras, Optolong filters and automation accessories — exactly what an astrophotographer needs. For anyone starting out or expanding their setup, it's the right place to research and buy with confidence.

---

## Final Thoughts

This is a constantly evolving setup. Each session reveals something new — a guiding limitation, an optimization opportunity for focus, or a new target worth exploring. The southern hemisphere offers unique and privileged targets, such as the Carina Nebula, the Magellanic Clouds and the galactic center — and that is exactly what motivates me to keep refining every component of this system.

In upcoming posts, I'll detail my complete workflow, from session planning to final image processing.

**Clear skies!** 🌌
