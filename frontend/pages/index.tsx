import { Inter } from 'next/font/google'
import PageHeading from '@/comps/PageHeading'

const inter = Inter({ subsets: ['latin'] })

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center py-2">
    <PageHeading>My Exchange</PageHeading>
  </div>
  )
}

/**
 * So you can build your landing page here, 
the connect wallet button would be on this page 
and it would appear on the navbar too
 */

 