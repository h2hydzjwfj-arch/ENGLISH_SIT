function nextReview(card, quality){
  let { interval = 0, ease = 2.5, reps = 0 } = card;
  if (quality < 3){ reps = 0; interval = 1; }
  else {
    reps++;
    if (reps === 1) interval = 1;
    else if (reps === 2) interval = 3;
    else interval = Math.round(interval * ease);
    ease = Math.max(1.3, ease + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)));
  }
  const due = Date.now() + interval * 24 * 60 * 60 * 1000;
  return { interval, ease: Math.round(ease * 100) / 100, reps, due };
}
module.exports = { nextReview };