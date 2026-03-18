import { AssetModel, AssetModelSchema, AssetCreateModel } from "../models/assets";
import { ModalityType } from "../models/shared";
import { z } from "zod";
import { apiClient } from "../api/client";

export class AssetsRepository {
  static async listAssets(modality?: ModalityType, adminAll: boolean = false): Promise<AssetModel[]> {
    const params = new URLSearchParams();
    if (modality) params.append("modality", modality);
    if (adminAll) params.append("admin_all", "true");

    const res = await apiClient.fetch(`/v1/assets?${params.toString()}`, { cache: 'no-store' });
    if (!res.ok) throw new Error("Failed to fetch assets");
    const data = await res.json();
    return z.array(AssetModelSchema).parse(data);
  }

  static async getAsset(id: string): Promise<AssetModel> {
    const res = await apiClient.fetch(`/v1/assets/${id}`, { cache: 'no-store' });
    if (!res.ok) throw new Error("Failed to fetch asset");
    const data = await res.json();
    return AssetModelSchema.parse(data);
  }

  static async createAsset(asset: AssetCreateModel): Promise<void> {
    const res = await apiClient.fetch(`/v1/assets`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(asset),
    });
    if (!res.ok) throw new Error("Failed to create asset");
  }

  static async deleteAsset(id: string): Promise<void> {
    const res = await apiClient.fetch(`/v1/assets/${id}`, {
      method: "DELETE",
    });
    if (!res.ok) throw new Error("Failed to delete asset");
  }
}
