const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'
const baseCdnUrl = process.env.NEXT_PUBLIC_CDN_URL || null
const buildId = process.env.NEXT_PUBLIC_BUILD_ID || null

const joinUrlSegments = (segments?: string[] | null) => {
  if (!segments || segments.length === 0) {
    return ''
  }

  const lastSegmentIndex = segments.length - 1

  const urlSegments = segments.map((segment, index) => {
    let urlSegment =
      index > 0 && segment.startsWith('/') ? segment.slice(1) : segment

    urlSegment =
      index < lastSegmentIndex && urlSegment.endsWith('/')
        ? urlSegment.slice(0, -1)
        : urlSegment

    return urlSegment
  })

  return urlSegments.join('/')
}

const getAbsoluteUrl = (path?: string) => {
  if (!path) {
    return baseUrl
  }

  return joinUrlSegments([baseUrl, path])
}

const getCdnUrl = (path?: string, includeFingerprint = true) => {
  if (!baseCdnUrl) {
    return path ?? ''
  }

  if (!path) {
    return baseCdnUrl
  }

  if (includeFingerprint && buildId) {
    return joinUrlSegments([baseCdnUrl, buildId, path])
  }

  return joinUrlSegments([baseCdnUrl, path])
}

export { getAbsoluteUrl, getCdnUrl }
