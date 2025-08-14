'use client'

import ImageWithLoading from '../../components/ImageWithLoading'

export default function TestImagePage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl mb-4">Image Loading Test</h1>
      
      <div className="mb-8">
        <h2 className="text-lg mb-2">Static Image Test</h2>
        <div className="w-64 h-64 border">
          <ImageWithLoading 
            src="/test-image.jpg"
            alt="Test static image"
            width={256}
            height={256}
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      <div className="mb-8">
        <h2 className="text-lg mb-2">API Image Test (Full)</h2>
        <div className="w-64 h-64 border">
          <ImageWithLoading 
            src="https://api.ufobeep.com/media/cc1c3aff-11e9-4769-9b65-4cd0619ed89a/UFOBeep_1755129502926.jpg"
            alt="Test API image"
            width={256}
            height={256}
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      <div className="mb-8">
        <h2 className="text-lg mb-2">API Image Test (Thumbnail)</h2>
        <div className="w-64 h-64 border">
          <ImageWithLoading 
            src="https://api.ufobeep.com/media/cc1c3aff-11e9-4769-9b65-4cd0619ed89a/UFOBeep_1755129502926.jpg?thumbnail=true"
            alt="Test API thumbnail"
            width={256}
            height={256}
            className="w-full h-full object-cover"
          />
        </div>
      </div>
    </div>
  )
}