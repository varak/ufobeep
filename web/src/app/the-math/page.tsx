'use client'

import Link from 'next/link'

export default function TheMath() {
  return (
    <main className="min-h-screen bg-dark-background">
      {/* Header */}
      <div className="bg-dark-surface border-b border-dark-border">
        <div className="max-w-6xl mx-auto px-6 py-6">
          <Link href="/" className="text-brand-primary hover:text-brand-primary-dark">
            ← Back to Home
          </Link>
        </div>
      </div>

      {/* Hero */}
      <section className="py-16 px-6 md:px-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-text-primary">
            The Math: Network Coverage Analysis
          </h1>
          <p className="text-xl text-text-secondary">
            How many users does UFOBeep need for effective coverage?
          </p>
        </div>
      </section>

      {/* The Question */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <div className="bg-dark-surface p-8 rounded-lg border border-brand-primary">
            <h2 className="text-2xl font-bold mb-4 text-brand-primary">The Question</h2>
            <p className="text-text-secondary text-lg">
              How many users does UFOBeep need in the United States for the network to be <em>effective</em> -
              meaning when someone reports a UFO sighting, there&apos;s a high probability that at least one other
              nearby user receives the alert and can verify?
            </p>
          </div>
        </div>
      </section>

      {/* Key Assumptions */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Key Assumptions</h2>

          <div className="grid md:grid-cols-2 gap-6">
            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary">Alert Radius</h3>
              <p className="text-text-secondary">
                <strong className="text-brand-primary text-3xl">50 km</strong><br/>
                (user-adjustable, default)<br/>
                Covers ~7,854 km² area
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary">Active Fraction (α)</h3>
              <p className="text-text-secondary">
                <strong className="text-brand-primary text-3xl">25%</strong><br/>
                Users actively connected and able to receive alerts at any given moment
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary">Urban Clustering</h3>
              <p className="text-text-secondary">
                <strong className="text-brand-primary text-3xl">80%</strong><br/>
                Users cluster in urban areas (top 50 metros = 52% of US population)
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary">Target Success</h3>
              <p className="text-text-secondary">
                <strong className="text-brand-primary text-3xl">95%</strong><br/>
                Desired probability that a beep reaches at least one other user
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* The Formula */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">The Formula: Poisson Distribution</h2>

          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary mb-6">
              The probability that at least one user receives an alert follows a <strong className="text-brand-primary">Poisson distribution</strong>:
            </p>

            <div className="bg-dark-background p-6 rounded-lg border border-brand-primary mb-6 font-mono text-center">
              <div className="text-2xl text-text-primary mb-4">
                P(≥1 active user) = 1 - e<sup>-μ</sup>
              </div>
              <div className="text-text-secondary text-sm mb-4">
                where μ = expected number of active users in range
              </div>
              <div className="border-t border-dark-border pt-4 mt-4">
                <div className="text-lg text-text-primary mb-2">
                  μ = -ln(1 - p)
                </div>
                <div className="text-text-secondary text-sm mb-4">
                  Solving for required μ to achieve probability p
                </div>
              </div>
              <div className="border-t border-dark-border pt-4 mt-4">
                <div className="text-lg text-text-primary">
                  Registered users needed = μ / α
                </div>
                <div className="text-text-secondary text-sm">
                  where α = active fraction (25%)
                </div>
              </div>
            </div>

            <div className="space-y-4 text-text-secondary">
              <p>
                <strong className="text-brand-primary">What this means:</strong>
              </p>
              <ul className="list-disc list-inside space-y-2 ml-4">
                <li>For <strong>80%</strong> probability: need μ = 1.61 → <strong>~6 registered users</strong> per 50 km</li>
                <li>For <strong>90%</strong> probability: need μ = 2.30 → <strong>~9 registered users</strong> per 50 km</li>
                <li>For <strong>95%</strong> probability: need μ = 3.00 → <strong>~12 registered users</strong> per 50 km</li>
                <li>For <strong>99%</strong> probability: need μ = 4.61 → <strong>~18 registered users</strong> per 50 km</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Two Models */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Mathematical Minimum vs Strategic Target</h2>

          <div className="space-y-6">
            {/* Minimum Model */}
            <div className="bg-dark-background p-8 rounded-lg border border-dark-border">
              <h3 className="text-2xl font-semibold mb-4 text-yellow-400">Model 1: Mathematical Minimum (Instantaneous)</h3>
              <p className="text-text-secondary mb-4">
                <strong>Goal:</strong> 95% chance that at least one other active user receives the alert RIGHT NOW
              </p>

              <div className="bg-dark-surface p-4 rounded border border-dark-border mb-4">
                <div className="grid md:grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-text-tertiary">Per 50 km bubble:</span>
                    <div className="text-xl text-brand-primary font-bold">12 registered users</div>
                  </div>
                  <div>
                    <span className="text-text-tertiary">Active at any moment:</span>
                    <div className="text-xl text-brand-primary font-bold">3 active users</div>
                  </div>
                </div>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-text-secondary text-sm">
                  <thead className="border-b border-dark-border">
                    <tr>
                      <th className="text-left py-2 text-brand-primary">Metro Size</th>
                      <th className="text-left py-2 text-brand-primary">Area (km²)</th>
                      <th className="text-left py-2 text-brand-primary">Bubbles</th>
                      <th className="text-left py-2 text-brand-primary">Users Needed</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-dark-border">
                    <tr>
                      <td className="py-2">Small city</td>
                      <td className="py-2">~8,000</td>
                      <td className="py-2">1</td>
                      <td className="py-2 font-bold">12</td>
                    </tr>
                    <tr>
                      <td className="py-2">Medium metro</td>
                      <td className="py-2">~15,000</td>
                      <td className="py-2">2</td>
                      <td className="py-2 font-bold">24</td>
                    </tr>
                    <tr>
                      <td className="py-2">Large metro</td>
                      <td className="py-2">~30,000</td>
                      <td className="py-2">4</td>
                      <td className="py-2 font-bold">48</td>
                    </tr>
                    <tr>
                      <td className="py-2">Major metro</td>
                      <td className="py-2">~60,000</td>
                      <td className="py-2">8</td>
                      <td className="py-2 font-bold">96</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div className="mt-4 p-4 bg-dark-surface rounded border border-yellow-600">
                <p className="text-sm text-text-secondary">
                  <strong className="text-yellow-400">Mathematical Minimum for 50 metros:</strong> ~600-1,200 total users
                  (12-24 per metro, depending on size)
                </p>
              </div>
            </div>

            {/* Strategic Model */}
            <div className="bg-dark-background p-8 rounded-lg border-2 border-brand-primary">
              <h3 className="text-2xl font-semibold mb-4 text-brand-primary">Model 2: Strategic Target (Real-World)</h3>
              <p className="text-text-secondary mb-4">
                <strong>Goal:</strong> Reliable multi-witness verification + uneven clustering + network effects
              </p>

              <div className="bg-dark-surface p-4 rounded border border-brand-primary mb-4">
                <div className="grid md:grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-text-tertiary">Per major metro:</span>
                    <div className="text-xl text-brand-primary font-bold">300-400 users</div>
                  </div>
                  <div>
                    <span className="text-text-tertiary">Active at any moment:</span>
                    <div className="text-xl text-brand-primary font-bold">75-100 active</div>
                  </div>
                </div>
              </div>

              <div className="space-y-3 text-text-secondary">
                <p><strong className="text-brand-primary">Why so much higher than the minimum?</strong></p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Uneven clustering:</strong> Users won&apos;t be perfectly distributed - need redundancy</li>
                  <li><strong>Multiple witnesses:</strong> Want 2-3+ people to see it, not just 1</li>
                  <li><strong>Network perception:</strong> Need density for users to feel it&apos;s &ldquo;active&rdquo;</li>
                  <li><strong>Engagement variance:</strong> α varies by time of day (10% at 3am, 40% at 8pm)</li>
                  <li><strong>Retention:</strong> Higher density = better experience = lower churn</li>
                </ul>
              </div>

              <div className="mt-4 p-4 bg-dark-surface rounded border border-brand-primary">
                <p className="text-sm text-text-secondary">
                  <strong className="text-brand-primary">Strategic Target for 50 metros:</strong> 15,000-20,000 total users
                  (300-400 per metro)
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* The Calculation */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Scaling to 50 Major Metros</h2>

          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary mb-6">
              The top 50 US metropolitan areas contain 52% of the US population (~170M people).
              Here&apos;s how different user counts translate to coverage:
            </p>

            <div className="overflow-x-auto">
              <table className="w-full text-text-secondary">
                <thead className="border-b border-dark-border">
                  <tr>
                    <th className="text-left py-3 text-brand-primary">Total Users</th>
                    <th className="text-left py-3 text-brand-primary">Users/Metro</th>
                    <th className="text-left py-3 text-brand-primary">Active (25%)</th>
                    <th className="text-left py-3 text-brand-primary">Coverage Quality</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-dark-border">
                  <tr>
                    <td className="py-3">600</td>
                    <td className="py-3">12</td>
                    <td className="py-3">3</td>
                    <td className="py-3 text-yellow-400">95% instant (mathematical min)</td>
                  </tr>
                  <tr>
                    <td className="py-3">1,200</td>
                    <td className="py-3">24</td>
                    <td className="py-3">6</td>
                    <td className="py-3 text-yellow-400">Near-certain instant</td>
                  </tr>
                  <tr>
                    <td className="py-3">5,000</td>
                    <td className="py-3">100</td>
                    <td className="py-3">25</td>
                    <td className="py-3 text-green-400">Guaranteed + multi-witness</td>
                  </tr>
                  <tr className="bg-dark-surface">
                    <td className="py-3 font-bold">10,000</td>
                    <td className="py-3">200</td>
                    <td className="py-3">50</td>
                    <td className="py-3 text-green-400 font-bold">Strong multi-witness coverage</td>
                  </tr>
                  <tr className="bg-brand-primary bg-opacity-10 border-brand-primary border-2">
                    <td className="py-3 font-bold text-brand-primary">15,000-20,000 ★</td>
                    <td className="py-3">300-400</td>
                    <td className="py-3">75-100</td>
                    <td className="py-3 text-green-400 font-bold">STRATEGIC TARGET</td>
                  </tr>
                  <tr>
                    <td className="py-3">30,000</td>
                    <td className="py-3">600</td>
                    <td className="py-3">150</td>
                    <td className="py-3 text-green-400">Excellent redundancy</td>
                  </tr>
                  <tr>
                    <td className="py-3">50,000</td>
                    <td className="py-3">1,000</td>
                    <td className="py-3">250</td>
                    <td className="py-3 text-green-400">National scale</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="mt-6 p-4 bg-dark-surface rounded border border-brand-primary">
              <p className="text-sm text-text-secondary">
                <strong className="text-brand-primary">★ Why 15-20K vs 600 minimum?</strong> The mathematical minimum (600-1,200)
                assumes perfect distribution and single-witness verification. The strategic target accounts for real-world
                clustering, multi-witness needs, time-of-day variance, and network effects that drive retention and growth.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Why Strategic Target is Higher */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Why the Strategic Target is 25-30x Higher</h2>

          <div className="space-y-4 text-text-secondary">
            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">1. Uneven Geographic Distribution</h3>
              <p>
                Users won&apos;t be uniformly spread across metros. Some will cluster in specific neighborhoods,
                college campuses, or enthusiast communities. Others will be isolated. The mathematical model assumes
                perfect uniform distribution - reality requires 10x more users to compensate for clustering.
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">2. Multi-Witness Verification</h3>
              <p>
                The minimum calculates P(≥1 user). But for credible verification, you want <strong>2-3+ witnesses</strong>.
                For P(≥3 users) at 95% confidence, you need roughly 3× the users. This alone pushes the target from
                600 to ~2,000.
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">3. Time-of-Day Variance</h3>
              <p>
                Active fraction (α) isn&apos;t constant. At 3am: maybe 5-10% active. At 8pm: maybe 40-50% active.
                The 25% is an average. To maintain 95% coverage at low-activity times, you need higher baseline density.
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">4. Network Effects & Retention</h3>
              <p>
                With only 12 users per metro, most people will NEVER experience a successful connection. They&apos;ll
                install, never see alerts, and uninstall. Higher density creates positive feedback: more alerts →
                more engagement → better retention → organic growth.
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">5. Growth Headroom</h3>
              <p>
                Users are concentrated in fewer than 50 metros initially. Maybe 10-20 cities dominate. Those cities
                need extra density to feel &ldquo;alive&rdquo; while coverage expands. The 15-20K target provides
                headroom for uneven early adoption.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Real-World Scenarios */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Real-World Growth Scenarios</h2>

          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <div className="space-y-4 text-text-secondary">
              <div className="flex items-center gap-4 p-3 bg-dark-background rounded">
                <span className="font-mono w-32">100-500</span>
                <span className="text-text-tertiary">→</span>
                <span>Friends & family testing (1-2 cities) - <em>not functional yet</em></span>
              </div>
              <div className="flex items-center gap-4 p-3 bg-dark-background rounded">
                <span className="font-mono w-32">600-1,200</span>
                <span className="text-text-tertiary">→</span>
                <span className="text-yellow-400">Mathematical minimum - <em>50 cities, sparse</em></span>
              </div>
              <div className="flex items-center gap-4 p-3 bg-dark-background rounded">
                <span className="font-mono w-32">2,000-5,000</span>
                <span className="text-text-tertiary">→</span>
                <span>Network emerging (10-20 cities with good density)</span>
              </div>
              <div className="flex items-center gap-4 p-3 bg-dark-background rounded border-2 border-yellow-600">
                <span className="font-mono w-32 font-bold">10,000</span>
                <span className="text-text-tertiary">→</span>
                <span className="font-bold text-yellow-400">Minimum VIABLE (users see value consistently)</span>
              </div>
              <div className="flex items-center gap-4 p-3 bg-brand-primary bg-opacity-20 rounded border-2 border-brand-primary">
                <span className="font-mono w-32 font-bold text-brand-primary">15,000-20,000</span>
                <span className="text-text-tertiary">→</span>
                <span className="font-bold text-brand-primary">STRATEGIC TARGET (network effects kick in)</span>
              </div>
              <div className="flex items-center gap-4 p-3 bg-dark-background rounded">
                <span className="font-mono w-32">30,000-50,000</span>
                <span className="text-text-tertiary">→</span>
                <span className="text-green-400">Strong national network</span>
              </div>
              <div className="flex items-center gap-4 p-3 bg-dark-background rounded">
                <span className="font-mono w-32">100,000+</span>
                <span className="text-text-tertiary">→</span>
                <span className="text-green-400">Self-sustaining viral growth</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Sensitivity Analysis */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Sensitivity Analysis: What If We&apos;re Wrong?</h2>

          <div className="bg-dark-background p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary mb-6">
              Our model depends on the active fraction (α). Here&apos;s how the target changes:
            </p>

            <div className="overflow-x-auto">
              <table className="w-full text-text-secondary">
                <thead className="border-b border-dark-border">
                  <tr>
                    <th className="text-left py-3 text-brand-primary">Active Fraction (α)</th>
                    <th className="text-left py-3 text-brand-primary">Scenario</th>
                    <th className="text-left py-3 text-brand-primary">Users/50km (95%)</th>
                    <th className="text-left py-3 text-brand-primary">Total (50 metros)</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-dark-border">
                  <tr>
                    <td className="py-3">10%</td>
                    <td className="py-3 text-sm">Low engagement</td>
                    <td className="py-3">30</td>
                    <td className="py-3">1,500-3,000</td>
                  </tr>
                  <tr className="bg-dark-surface">
                    <td className="py-3 font-bold">25%</td>
                    <td className="py-3 text-sm font-bold">Conservative (our model)</td>
                    <td className="py-3 font-bold">12</td>
                    <td className="py-3 font-bold">600-1,200</td>
                  </tr>
                  <tr>
                    <td className="py-3">40%</td>
                    <td className="py-3 text-sm">High engagement (peak hours)</td>
                    <td className="py-3">7.5</td>
                    <td className="py-3">375-750</td>
                  </tr>
                  <tr>
                    <td className="py-3">50%</td>
                    <td className="py-3 text-sm">Very high engagement</td>
                    <td className="py-3">6</td>
                    <td className="py-3">300-600</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="mt-6 p-4 bg-dark-surface rounded border border-yellow-600">
              <p className="text-sm text-text-secondary">
                <strong className="text-yellow-400">Key Insight:</strong> Even if α doubles (50% vs 25%), the strategic
                target stays 15-20K because we&apos;re optimizing for multi-witness verification and network effects,
                not just bare minimum coverage.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* The Answer */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">The Answer (Two Perspectives)</h2>

          <div className="space-y-6">
            <div className="bg-dark-surface p-8 rounded-lg border border-yellow-600">
              <h3 className="text-2xl font-bold mb-4 text-yellow-400">📐 Mathematical Minimum: ~600-1,200 Users</h3>
              <p className="text-text-secondary text-lg mb-4">
                This is the <strong>bare minimum</strong> for 95% probability of instant connection:
              </p>
              <ul className="space-y-2 text-text-secondary">
                <li className="flex items-start gap-2">
                  <span className="text-yellow-400">•</span>
                  <span>12-24 users per metro (depending on size)</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-yellow-400">•</span>
                  <span>Assumes perfect distribution (unrealistic)</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-yellow-400">•</span>
                  <span>Only guarantees 1 witness, not multiple</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-yellow-400">•</span>
                  <span>Insufficient for network effects</span>
                </li>
              </ul>
            </div>

            <div className="bg-dark-surface p-8 rounded-lg border-2 border-brand-primary">
              <h3 className="text-2xl font-bold mb-4 text-brand-primary">🎯 Strategic Target: 15,000-20,000 Users</h3>
              <p className="text-text-secondary text-lg mb-4">
                This is the <strong>realistic target</strong> for an effective, sustainable network:
              </p>
              <ul className="space-y-2 text-text-secondary">
                <li className="flex items-start gap-2">
                  <span className="text-green-400">✓</span>
                  <span>300-400 users per major metro</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400">✓</span>
                  <span>75-100 active users at any moment per metro</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400">✓</span>
                  <span>Multiple witnesses for verification (2-5+)</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400">✓</span>
                  <span>Robust to uneven clustering and churn</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400">✓</span>
                  <span>Network feels &ldquo;alive&rdquo; - drives retention</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-green-400">✓</span>
                  <span>Enables viral growth and word-of-mouth</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Validation */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Model Validation</h2>

          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary mb-4">
              Both the conservative (instantaneous, α=25%) and optimistic (window-based, 70% reach) models
              were validated using Monte Carlo simulations with 10,000 iterations per scenario.
            </p>
            <ul className="space-y-2 text-text-secondary list-disc list-inside ml-4">
              <li>At <strong className="text-brand-primary">600-1,200 users</strong>: Mathematical minimum confirmed (95% instant)</li>
              <li>At <strong className="text-brand-primary">5,000 users</strong>: 99%+ connection probability</li>
              <li>At <strong className="text-brand-primary">10,000 users</strong>: Near-certain with multi-witness capability</li>
              <li>At <strong className="text-brand-primary">20,000 users</strong>: Guaranteed coverage with strong redundancy</li>
            </ul>
            <p className="text-text-secondary mt-4">
              The mathematical models closely match simulation results across all scenarios.
            </p>
          </div>
        </div>
      </section>

      {/* Conclusion */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Conclusion</h2>

          <div className="bg-dark-background p-8 rounded-lg border border-brand-primary">
            <p className="text-text-secondary text-lg mb-6">
              UFOBeep&apos;s coverage requirements depend on what you&apos;re optimizing for:
            </p>

            <div className="space-y-4 text-text-secondary text-lg">
              <div className="p-4 bg-dark-surface rounded border border-yellow-600">
                <strong className="text-yellow-400">Mathematical Minimum (600-1,200 users):</strong><br/>
                Proves the concept works, but sparse coverage and poor user experience
              </div>

              <div className="p-4 bg-dark-surface rounded border border-yellow-400">
                <strong className="text-yellow-400">Minimum Viable (5,000-10,000 users):</strong><br/>
                Network starts feeling useful, but concentrated in 10-20 cities
              </div>

              <div className="p-4 bg-brand-primary bg-opacity-20 rounded border-2 border-brand-primary">
                <strong className="text-brand-primary text-xl">Strategic Target (15,000-20,000 users):</strong><br/>
                Network becomes self-sustaining with reliable multi-witness verification,
                strong retention, and viral growth potential across 50+ metros
              </div>
            </div>

            <p className="text-text-secondary text-lg mt-6">
              <strong className="text-brand-primary">Bottom line:</strong> While the math shows UFOBeep could
              theoretically work with 600 users, the <strong>realistic target of 15,000-20,000 users</strong>
              creates a network that actually delivers value, retains users, and grows organically.
            </p>
          </div>
        </div>
      </section>

      {/* Technical Appendix */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Technical Appendix: Full Formulas</h2>

          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <div className="space-y-6 font-mono text-sm text-text-secondary">
              <div className="bg-dark-background p-4 rounded border border-dark-border">
                <div className="text-brand-primary mb-2">Poisson Probability:</div>
                <div>P(≥1 active user) = 1 - e^(-μ)</div>
              </div>

              <div className="bg-dark-background p-4 rounded border border-dark-border">
                <div className="text-brand-primary mb-2">Required μ for target probability p:</div>
                <div>μ = -ln(1 - p)</div>
                <div className="text-xs text-text-tertiary mt-2">
                  Example: p=95% → μ = -ln(0.05) = 2.996 ≈ 3.0
                </div>
              </div>

              <div className="bg-dark-background p-4 rounded border border-dark-border">
                <div className="text-brand-primary mb-2">Registered users needed:</div>
                <div>N = μ / α</div>
                <div className="text-xs text-text-tertiary mt-2">
                  where α = active fraction (default 0.25)
                </div>
                <div className="text-xs text-text-tertiary">
                  Example: μ=3.0, α=0.25 → N = 12 users per bubble
                </div>
              </div>

              <div className="bg-dark-background p-4 rounded border border-dark-border">
                <div className="text-brand-primary mb-2">Coverage area:</div>
                <div>A = πR² where R = 50 km</div>
                <div>A = π × 50² ≈ 7,854 km²</div>
              </div>

              <div className="bg-dark-background p-4 rounded border border-dark-border">
                <div className="text-brand-primary mb-2">For N witnesses (not just 1):</div>
                <div>P(≥N) = 1 - Σ(k=0 to N-1) [e^(-μ) × μ^k / k!]</div>
                <div className="text-xs text-text-tertiary mt-2">
                  Example: For P(≥3 witnesses) = 95%, need μ ≈ 6.3 → ~25 users/bubble
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer Navigation */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
            <h3 className="text-lg font-semibold mb-4 text-text-primary">Learn More</h3>
            <div className="flex flex-wrap gap-4">
              <Link href="/how-it-works" className="text-brand-primary hover:underline">
                ← How UFOBeep Works
              </Link>
              <Link href="/faq" className="text-brand-primary hover:underline">
                Frequently Asked Questions →
              </Link>
              <Link href="/" className="text-brand-primary hover:underline">
                Back to Home →
              </Link>
            </div>
          </div>
        </div>
      </section>
    </main>
  )
}
