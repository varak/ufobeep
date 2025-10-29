'use client'

import Link from 'next/link'

export default function Trailer() {
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

      {/* Video Section */}
      <section className="py-16 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-8">
            <h1 className="text-4xl md:text-5xl font-bold mb-6 text-text-primary">
              UFOBeep Trailer
            </h1>
            <p className="text-xl text-text-secondary">
              See what real-time UFO alerts look like
            </p>
          </div>

          {/* Video Player */}
          <div className="bg-dark-surface rounded-lg border border-brand-primary overflow-hidden">
            <video
              controls
              autoPlay
              loop
              muted
              playsInline
              className="w-full"
              poster="/trailer-poster.jpg"
            >
              <source src="/trailer.mp4" type="video/mp4" />
              Your browser does not support the video tag.
            </video>
          </div>

          {/* CTA Below Video */}
          <div className="text-center mt-8 space-y-4">
            <p className="text-lg text-text-secondary">
              Ready to get alerts when UFOs are sighted near you?
            </p>
            <div className="flex flex-col sm:flex-row gap-4 items-center justify-center">
              <Link
                href="/download"
                className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all shadow-glow hover:shadow-xl hover:scale-105 transform"
              >
                Download UFOBeep
              </Link>
              <Link
                href="/how-it-works"
                className="border border-brand-primary text-brand-primary px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary hover:text-text-inverse transition-all hover:scale-105 transform"
              >
                How It Works
              </Link>
            </div>
          </div>

          {/* Share Section */}
          <div className="mt-12 bg-dark-surface p-6 rounded-lg border border-dark-border text-center">
            <h3 className="text-lg font-semibold mb-3 text-text-primary">Share the Trailer</h3>
            <p className="text-text-secondary mb-4">
              Help spread the word about real-time UFO alerts
            </p>
            <div className="flex flex-wrap gap-3 justify-center">
              <a
                href={`https://twitter.com/intent/tweet?text=Check%20out%20UFOBeep%20-%20real-time%20UFO%20sighting%20alerts!&url=https://ufobeep.com/trailer`}
                target="_blank"
                rel="noopener noreferrer"
                className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors"
              >
                Share on X/Twitter
              </a>
              <a
                href={`https://www.reddit.com/submit?url=https://ufobeep.com/trailer&title=UFOBeep%20-%20Real-time%20UFO%20Sighting%20Alerts`}
                target="_blank"
                rel="noopener noreferrer"
                className="bg-orange-600 text-white px-6 py-2 rounded-lg hover:bg-orange-700 transition-colors"
              >
                Share on Reddit
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
  )
}
