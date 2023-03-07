import { Inter } from 'next/font/google'
import PageHeading from '@/comps/PageHeading'

const inter = Inter({ subsets: ['latin'] })

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center py-2">
    <PageHeading>Admin Page</PageHeading>
  </div>
  )
}

/**
 * This is where all the minting buttons would be
 * mint moli, mint lima
 */