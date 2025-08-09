export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-6 md:p-24">
      <div className="text-center">
        <div className="text-6xl mb-6">👽</div>
        <h1 className="text-4xl md:text-5xl font-bold mb-4 text-text-primary">
          UFOBeep
        </h1>
        <p className="text-lg md:text-xl text-text-secondary mb-8">
          Real-time sighting alerts
        </p>
        <div className="flex flex-col sm:flex-row gap-4 items-center justify-center">
          <button className="bg-brand-primary text-text-inverse px-6 py-3 rounded-md font-semibold hover:bg-brand-primary-dark transition-colors">
            Download App
          </button>
          <button className="border border-brand-primary text-brand-primary px-6 py-3 rounded-md font-semibold hover:bg-brand-primary hover:text-text-inverse transition-colors">
            Learn More
          </button>
        </div>
      </div>
    </main>
  )
}