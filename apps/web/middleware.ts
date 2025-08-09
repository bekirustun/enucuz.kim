import { NextRequest, NextResponse } from 'next/server'

export function middleware(req: NextRequest) {
  // Basit örnek: Türkçe sayfa yönlendirme
  if (req.nextUrl.pathname === '/') {
    // istersen kullanıcıyı /tr/ ana sayfasına yönlendirebilirsin
  }
  return NextResponse.next()
}
