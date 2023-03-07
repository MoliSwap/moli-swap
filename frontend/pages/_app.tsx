import Layout from '@/comps/Layout'
import '@/styles/globals.css'
import type { AppProps } from 'next/app'

export default function App({ Component, pageProps }: AppProps) {
  return (
    <Layout>
    <Component {...pageProps} />
  </Layout>
)
}

/**
 * I can not remember how they implimented the toast, 
 * but if it is implemented as a component, then you 
 * would need to add it here so that all the pages 
 * can call it
 * 
 * please do not put the connect wallet here.
 */