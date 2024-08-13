import { z } from "zod"

export type TabId = z.infer<typeof tabIdSchema>
export const tabIdSchema = z.object({ tabId: z.string() })
