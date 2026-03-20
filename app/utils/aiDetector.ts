/**
 * Simplified AI Detection Heuristics
 * In a real-world app, this would call an API like GPTZero or Originality.ai
 */
export const scanForAI = (text: string): number => {
  if (!text || text.length < 50) return 10 // Too short to be "AI" usually

  let score = 30 // Base score

  // 1. Check for "AI phrases" or overly formal transitions
  const aiPhrases = [
    'in conclusion', 'it is important to note', 'furthermore',
    'moreover', 'delve into', 'tapestry of', 'testament to',
    'comprehensive', 'proactive', 'leveraging'
  ]

  aiPhrases.forEach((phrase) => {
    if (text.toLowerCase().includes(phrase)) score += 15
  })

  // 2. Sentence structure patterns (AI often uses bullet points with colons)
  if (text.includes(':') && text.split('\n').some(line => line.trim().startsWith('-') || line.trim().startsWith('*'))) {
    score += 20
  }

  // 3. Perfect punctuation and casing (human cabin crew applications on Roblox are usually slightly messy)
  const isPerfect = /^[A-Z]/.test(text) && text.endsWith('.') && !text.includes('  ')
  if (isPerfect) score += 10

  // 4. Randomize slightly for "scanner" feel
  score += Math.floor(Math.random() * 15)

  return Math.min(score, 99) // Max 99%
}
