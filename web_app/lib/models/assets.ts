import { z } from "zod";
import { ModalityTypeEnum } from "./shared";

export const AnnotateFieldModelSchema = z.object({
  name: z.string(),
  modality: ModalityTypeEnum,
  description: z.string(),
});

export type AnnotateFieldModel = z.infer<typeof AnnotateFieldModelSchema>;

export const AssetModelSchema = z.object({
  id: z.string(),
  dataset_id: z.string(),
  dataset_batch_key: z.string(),
  modality: ModalityTypeEnum,
  name: z.string(),
  description: z.string(),
  created_at: z.string(),
  updated_at: z.string(),
  annotate_fields: z.array(AnnotateFieldModelSchema),
  tags: z.array(z.string()).default([]),
  total_publishes: z.number().default(0),
});

export type AssetModel = z.infer<typeof AssetModelSchema>;

export const AssetCreateModelSchema = z.object({
  dataset_id: z.string().min(1, "Dataset is required"),
  name: z.string().min(1, "Name is required"),
  description: z.string().min(1, "Description is required"),
  annotate_fields: z.array(AnnotateFieldModelSchema).min(1, "At least one field is required"),
  tags: z.array(z.string()).default([]),
});

export type AssetCreateModel = z.infer<typeof AssetCreateModelSchema>;
