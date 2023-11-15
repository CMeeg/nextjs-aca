'use client'

import ReactDOM from 'react-dom'
import { getCdnUrl } from '@/lib/url'

function PreloadResources() {
  const cdnUrl = getCdnUrl('', false)

  if (cdnUrl.length > 0) {
    // @ts-ignore
    ReactDOM.preconnect(cdnUrl)
  }

  return null
}

export { PreloadResources }
