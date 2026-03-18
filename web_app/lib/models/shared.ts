import { z } from "zod";

export const ModalityTypeEnum = z.enum(["text", "image", "audio", "video"]);
export type ModalityType = z.infer<typeof ModalityTypeEnum>;
