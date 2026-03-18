import { AssetModel, AssetModelSchema, AssetCreateModel, AssetPublishModel, AssetPublishModelSchema } from "../models/assets";
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

  static async listPublishes(assetId: string): Promise<AssetPublishModel[]> {
    const res = await apiClient.fetch(`/v1/assets/publishes?asset_id=${assetId}`, { cache: 'no-store' });
    if (!res.ok) throw new Error("Failed to fetch publishes");
    const data = await res.json();
    return z.array(AssetPublishModelSchema).parse(data);
  }

  static async createPublishDownloadUrl(assetId: string, publisherId: string): Promise<{ url: string; expires_in: number }> {
    const res = await apiClient.fetch(`/v1/assets/publish-download-url`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ asset_id: assetId, publisher_id: publisherId }),
    });
    if (!res.ok) throw new Error("Failed to create publish download URL");
    return res.json();
  }
}
