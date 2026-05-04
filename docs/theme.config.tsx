import React from 'react'
import { DocsThemeConfig } from 'nextra-theme-docs'
import Image from 'next/image'

const config: DocsThemeConfig = {
  logo: (
    <Image
      src="/logo.png"
      alt="AutoGuard VPN"
      width={80}
      height={80}
      style={{
        borderRadius: '4px',
        height: 'clamp(36px, 4vw, 48px)',
        width: 'auto',
        display: 'block',
        margin: '6px 0',
      }}
    />
  ),
  project: {
    link: 'https://github.com/ElvinSuleymanov/AutoGuard-VPN',
  },
  docsRepositoryBase: 'https://github.com/ElvinSuleymanov/AutoGuard-VPN/tree/main/docs',
  head: (
    <>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta name="description" content="AutoGuard VPN — self-hosted WireGuard with ad-blocking DNS" />
      <link rel="icon" href="/logo.png" />
    </>
  ),
  nextThemes: {
    defaultTheme: 'dark',
  },
  sidebar: {
    defaultMenuCollapseLevel: 1,
    toggleButton: true,
  },
  footer: {
    content: 'AutoGuard VPN Documentation — MIT License',
  },
}

export default config
