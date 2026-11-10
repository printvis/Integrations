function findSectionRange(md, heading = "release notes") {
  const lines = (md || "").split(/\r?\n/);
  let headingLineIndex = -1;
  let contentStartIndex = -1;
  let level = 2;

  for (let i = 0; i < lines.length; i++) {
    const match = lines[i].match(/^(#{1,6})\s+(.*)\s*$/);
    if (!match) continue;

    const currentLevel = match[1].length;
    const title = match[2].trim().toLowerCase();
    if (title === heading.toLowerCase()) {
      headingLineIndex = i;
      contentStartIndex = i + 1;
      level = currentLevel;
      break;
    }
  }

  if (headingLineIndex === -1) {
    return null;
  }

  let endIndex = lines.length;
  for (let i = contentStartIndex; i < lines.length; i++) {
    const match = lines[i].match(/^(#{1,6})\s+/);
    if (!match) continue;

    const currentLevel = match[1].length;
    if (currentLevel <= level) {
      endIndex = i;
      break;
    }
  }

  return {
    headingLineIndex,
    contentStartIndex,
    endIndex,
    lines
  };
}

function hasSection(md, heading = "release notes") {
  return findSectionRange(md, heading) !== null;
}

function extractSection(md, heading = "release notes") {
  const range = findSectionRange(md, heading);
  if (!range) {
    return null;
  }

  const content = range.lines.slice(range.contentStartIndex, range.endIndex).join("\n").trim();
  return content || null;
}

module.exports = {
  extractSection,
  hasSection
};
