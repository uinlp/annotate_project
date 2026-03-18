import { DatasetModel, DatasetModelSchema, DatasetCreateModel } from "../models/datasets";
import { z } from "zod";
import { apiClient } from "../api/client";

export class DatasetsRepository {
  static async listDatasets(): Promise<DatasetModel[]> {
    const res = await apiClient.fetch(`/v1/datasets`, { cache: 'no-store' });
    if (!res.ok) throw new Error("Failed to fetch datasets");
    const data = await res.json();
    return z.array(DatasetModelSchema).parse(data);
  }

  static async getDataset(id: string): Promise<DatasetModel> {
    const res = await apiClient.fetch(`/v1/datasets/${id}`, { cache: 'no-store' });
    if (!res.ok) throw new Error("Failed to fetch dataset");
    const data = await res.json();
    return DatasetModelSchema.parse(data);
  }

  static async createDataset(dataset: DatasetCreateModel): Promise<{ url: string; expires_in: number }> {
    const res = await apiClient.fetch(`/v1/datasets`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(dataset),
    });
    if (!res.ok) throw new Error("Failed to create dataset");
    return res.json();
  }

  static async deleteDataset(id: string): Promise<void> {
    const res = await apiClient.fetch(`/v1/datasets/${id}`, {
      method: "DELETE",
    });
    if (!res.ok) throw new Error("Failed to delete dataset");
  }
}
