# Web Marketing & Positioning Guide

> ARC Labs Studio — ARCKnowledge-Web
> Best practices for positioning, SEO, CRO, and content strategy in web projects.
> Applies to studio projects and client projects alike.

---

## 1. Before You Build — Define Positioning First

Every web project needs a clear answer to these questions before writing a single line of code:

```markdown
## Project Marketing Context

- **Product/Service:** [what it is]
- **Target Audience:** [who it's for — be specific]
- **Core Value Proposition:** [what problem it solves and why this solution]
- **Primary CTA:** [one single action you want visitors to take]
- **Differentiator:** [why this over alternatives]
- **Elevator Pitch:** [one sentence]
```

> **Rule:** If you can't write the elevator pitch in one sentence, the positioning isn't clear enough yet. Clarify before building.

Store this as `app-marketing-context.md` in the project root and `.claude/` so AI agents can reference it automatically.

---

## 2. Page Structure — Conversion-First Architecture

Structure every marketing page to answer the visitor's implicit questions in order:

| Section | Visitor question answered | Goal |
|---|---|---|
| Hero | "What is this?" | Immediate clarity — value prop in <5 seconds |
| Problem/Pain | "Is this for me?" | Build empathy, qualify the visitor |
| Solution | "How does it solve it?" | Connect problem to product |
| Proof | "Should I trust this?" | Social proof, testimonials, logos, data |
| Features/Benefits | "What exactly do I get?" | Detail for considered buyers |
| FAQ | "What's stopping me?" | Eliminate objections |
| CTA | "What do I do next?" | Single clear next step |

> **Rule:** One page, one goal, one primary CTA. Secondary CTAs should be visually subordinate.

---

## 3. SEO Fundamentals

### On-page basics (every page)
- `<title>` tag: `Primary Keyword — Brand Name` (50-60 chars)
- `<meta description>`: benefit-led, 150-160 chars, includes CTA
- One `<h1>` per page, matches search intent
- `<h2>`/`<h3>` hierarchy — logical, keyword-informed
- Alt text on all images (descriptive, not keyword-stuffed)
- Canonical URLs configured

### Technical SEO checklist
- [ ] Sitemap.xml generated and submitted
- [ ] robots.txt configured
- [ ] Structured data (Schema.org) for relevant content types
- [ ] Open Graph + Twitter Card meta tags
- [ ] Page speed: LCP < 2.5s, CLS < 0.1, FID < 100ms (Core Web Vitals)
- [ ] HTTPS + valid SSL
- [ ] Mobile-first responsive design
- [ ] No broken links, no 404s on main pages

### Content strategy
- Write for humans first, search engines second
- Target one primary keyword per page
- Support with 2-4 related secondary keywords
- Answer the question behind the keyword, not just the keyword itself

---

## 4. AI Search Optimization (LLM Citation)

As of 2025+, appearing in AI-generated answers (ChatGPT, Claude, Gemini, Perplexity) is increasingly important alongside traditional SEO.

### How to get cited by LLMs
- **Be definitive:** Write clear, factual statements that an AI can confidently quote
- **Use structured content:** Headers, bullet points, tables — LLMs parse structured text better
- **Answer questions directly:** Use FAQ sections with question-format headers
- **Build topical authority:** Multiple pieces of content on the same topic cluster
- **Schema markup:** Helps LLMs understand what type of content you have

### LLM-friendly page patterns
```html
<!-- Good for LLM citation -->
<h2>What is [Product]?</h2>
<p>[Product] is a [category] that [specific benefit] for [audience].</p>

<!-- FAQ schema -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [...]
}
</script>
```

---

## 5. Copywriting Standards

### Core principles
1. **Clarity over cleverness** — if you have to choose, choose clarity
2. **Benefits over features** — "Save 2 hours/week" not "Automated workflow engine"
3. **Specific over vague** — numbers, outcomes, concrete examples
4. **Active over passive** — "We build X" not "X is built by us"
5. **No jargon** unless the audience uses it themselves

### Headlines
- Lead with the outcome, not the mechanism
- Avoid: "The ultimate solution for...", "Revolutionary...", "Best-in-class..."
- Use: "[Outcome] for [Audience]" / "Stop [Problem]. Start [Outcome]."

### CTAs
| Weak | Strong |
|---|---|
| Submit | Get Started Free |
| Sign Up | Create My Account |
| Learn More | See How It Works |
| Contact | Talk to a Human |

**Formula:** [Verb] + [Specific thing they get] + [Qualifier if needed]

---

## 6. Conversion Rate Optimization (CRO)

### Friction reduction checklist
- [ ] Primary CTA visible above the fold without scrolling
- [ ] Form fields: only ask for what you actually need
- [ ] No registration required for the first "aha moment"
- [ ] Social proof near every CTA (testimonials, logos, user count)
- [ ] Trust signals visible (SSL badge, privacy policy link, no-spam note)
- [ ] Loading states and error messages are clear and human

### A/B testing approach
- Test one variable at a time
- Run until statistical significance (minimum 95% confidence)
- Priority order: headline → CTA → hero image → pricing → form length
- Document all tests and results in `projects/ab-tests.md`

---

## 7. Analytics Setup (Minimum Viable)

Every project should have analytics from day one:

```markdown
## Analytics Checklist
- [ ] Analytics tool configured (Plausible / Umami / GA4)
- [ ] Goals/conversions defined and tracked
- [ ] UTM parameters on all external links
- [ ] Funnel defined: entry → engagement → conversion
- [ ] Weekly review scheduled
```

**Preferred for privacy-first projects:** Plausible or Umami (GDPR-friendly, no cookies, self-hostable)

### Key metrics to track
- **Acquisition:** Traffic by source, organic vs paid vs direct
- **Engagement:** Bounce rate, scroll depth, time on page
- **Conversion:** CTA clicks, sign-ups, downloads, purchases
- **Retention:** Return visits, newsletter open rate

---

## 8. Launch Checklist

Before going live with any marketing-facing web project:

### Content
- [ ] All placeholder text replaced
- [ ] All images have alt text
- [ ] Privacy policy and terms of service pages exist
- [ ] Contact information is accurate

### Technical
- [ ] Core Web Vitals passing (Lighthouse score ≥ 90)
- [ ] Mobile tested on real device (not just browser DevTools)
- [ ] Cross-browser tested (Chrome, Safari, Firefox)
- [ ] 404 page exists and is on-brand
- [ ] Analytics configured and verified

### SEO
- [ ] Title tags and meta descriptions on all pages
- [ ] Sitemap submitted to Google Search Console
- [ ] Open Graph images set (1200×630px)
- [ ] Structured data validated (schema.org validator)

### Marketing
- [ ] Social media profiles link to the site
- [ ] Email capture or CTA configured
- [ ] Launch announcement drafted

---

## 9. App-Specific Web Considerations

When the web project is for a mobile app (App Store or Google Play):

- **Primary CTA** should link directly to the App Store / Play Store page
- Include **app store badges** (official assets from Apple/Google)
- Add **App Store structured data** (schema.org/SoftwareApplication)
- **App Preview screenshots** on the web should match App Store screenshots
- **Deep link** support: consider universal links for iOS / app links for Android
- **Smart app banners** for mobile web visitors (`<meta name="apple-itunes-app">`)

---

*Last updated: 2026-03 — ARC Labs Studio*
*Part of ARCKnowledge-Web — applies to all studio and client web projects*
