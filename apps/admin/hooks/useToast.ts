export function useToast(){ return { success: (m:string)=>console.log(m), error:(m:string)=>console.error(m) }; }
