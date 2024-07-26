// Function to parse mouse events
// https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Button-event-tracking
export function validateMouseEvent(data: string): string | undefined {
  const match = /\x1b\[<(\d+);(\d+);(\d+)([mM])/.exec(data)
  if (match) {
    const buttonCode = parseInt(match[1], 10)
    const column = parseInt(match[2], 10)
    const row = parseInt(match[3], 10)
    const isRelease = match[4] === "m"

    console.log(
      `Mouse event: buttonCode=${buttonCode}, column=${column}, row=${row}, isRelease=${isRelease}`,
    )

    return data
  }
}
