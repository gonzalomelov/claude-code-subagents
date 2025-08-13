/** @type {import("markdownlint").Rule} */
module.exports = {
  names: ["action-items-structure", "AIS"],
  description: "ACTION ITEMS section must only contain allowed subsections",
  information: new URL("https://example.com/rules/action-items-structure"),
  tags: ["structure"],
  parser: "micromark",
  function: (params, onError) => {
    const lines = params.lines;
    let inActionItems = false;
    let foundImmediate = false;
    let foundRecommended = false;
    let immediateComplete = false;
    let recommendedComplete = false;
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const lineNumber = i + 1;
      
      // Check if we're entering ACTION ITEMS section
      if (line.trim() === "## 🎯 ACTION ITEMS") {
        inActionItems = true;
        continue;
      }
      
      // Check if we're leaving ACTION ITEMS section (entering a new ## section)
      if (inActionItems && line.match(/^##\s/)) {
        inActionItems = false;
        break;
      }
      
      // If we're in ACTION ITEMS section
      if (inActionItems) {
        // Check for allowed subsections
        if (line.trim() === "**Immediate Actions Required:**") {
          foundImmediate = true;
          immediateComplete = false;
          continue;
        }
        
        if (line.trim() === "**Recommended Improvements:**") {
          foundRecommended = true;
          recommendedComplete = false;
          immediateComplete = true; // Previous section is complete
          continue;
        }
        
        // Check for any other bold text that looks like a subsection header
        if (line.match(/^\*\*[^*]+:\*\*$/)) {
          // This is a bold text ending with colon - likely a subsection header
          if (!foundImmediate || !foundRecommended) {
            // Still expecting the required subsections
            continue;
          }
          
          // Found an unexpected subsection
          onError({
            lineNumber: lineNumber,
            detail: "ACTION ITEMS section should only contain 'Immediate Actions Required' and 'Recommended Improvements' subsections",
            context: line.trim(),
            fixInfo: {
              lineNumber: lineNumber,
              deleteCount: -1 // Delete the entire line
            }
          });
        }
      }
    }
  }
};