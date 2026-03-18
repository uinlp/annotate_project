import { z } from "zod";
import { ModalityTypeEnum } from "./shared";

export const DatasetModelSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string(),
  modality: ModalityTypeEnum,
  batch_size: z.number(),
  batch_keys: z.array(z.string()).default([]),
  created_at: z.string(),
  updated_at: z.string(),
  is_completed: z.boolean().default(false),
  is_deleted: z.boolean().default(false),
});

export type DatasetModel = z.infer<typeof DatasetModelSchema>;

export const DatasetCreateModelSchema = z.object({
  name: z.string().min(1, "Name is required"),
  description: z.string().min(1, "Description is required"),
  modality: ModalityTypeEnum,
  batch_size: z.coerce.number().min(1, "Batch size must be at least 1"),
});

export type DatasetCreateModel = z.infer<typeof DatasetCreateModelSchema>;
