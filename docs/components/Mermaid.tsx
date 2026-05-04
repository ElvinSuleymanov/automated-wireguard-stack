'use client'

import { useEffect, useRef } from 'react'

interface MermaidProps {
  chart: string
}

export default function Mermaid({ chart }: MermaidProps) {
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    import('mermaid').then((m) => {
      m.default.initialize({
        startOnLoad: false,
        theme: 'base',
        themeVariables: {
          background: '#060b14',
          primaryColor: '#0d1b2a',
          primaryTextColor: '#cdd9e5',
          primaryBorderColor: '#1e3a5f',
          lineColor: '#38bdf8',
          secondaryColor: '#0d1b2a',
          tertiaryColor: '#0d1b2a',
          edgeLabelBackground: '#060b14',
          clusterBkg: '#0a1628',
          clusterBorder: '#1e3a5f',
          titleColor: '#7dd3fc',
          fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
        },
      })
      if (ref.current) {
        const id = `mermaid-${Math.random().toString(36).slice(2)}`
        m.default.render(id, chart).then(({ svg }) => {
          if (ref.current) ref.current.innerHTML = svg
        })
      }
    })
  }, [chart])

  return (
    <div
      ref={ref}
      style={{
        background: 'linear-gradient(135deg, #060b14 0%, #0a1628 100%)',
        borderRadius: '12px',
        border: '1px solid #1e3a5f',
        padding: '2rem',
        overflowX: 'auto',
        margin: '1.5rem 0',
        boxShadow: '0 0 40px rgba(14, 165, 233, 0.08)',
      }}
    />
  )
}
