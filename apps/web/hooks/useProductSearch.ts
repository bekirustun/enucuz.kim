import useSWR from 'swr'
import axios from 'axios'

export function useProductSearch(query: string) {
  const fetcher = (url: string) => axios.get(url).then(res => res.data)
  const { data, error, isLoading } = useSWR(
    query ? `/api/search?query=${encodeURIComponent(query)}` : null,
    fetcher
  )
  return {
    products: data,
    isLoading,
    isError: error
  }
}
