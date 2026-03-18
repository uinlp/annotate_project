"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { AssetsRepository } from "@/lib/repositories/assets";
import { DatasetsRepository } from "@/lib/repositories/datasets";
import { AssetCreateModelSchema } from "@/lib/models/assets";
import { Plus, Trash2 } from "lucide-react";

export default function UploadAssetPage() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    dataset_id: "",
    tags: "",
  });

  const [annotateFields, setAnnotateFields] = useState([{ name: "", description: "", modality: "text" }]);

  const { data: datasets = [], isPending: datasetsLoading } = useQuery({
    queryKey: ['datasets'],
    queryFn: () => DatasetsRepository.listDatasets(),
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    
    try {
      const parsedData = AssetCreateModelSchema.parse({
        ...formData,
        tags: formData.tags.split(",").map(t => t.trim()).filter(Boolean),
        annotate_fields: annotateFields
      });
      await AssetsRepository.createAsset(parsedData);
      router.push("/admin/assets");
      router.refresh();
    } catch (err: any) {
      if (err.errors) {
        setError(err.errors[0].message);
      } else {
        setError(err.message || "An error occurred");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto space-y-8 py-8">
      <div>
        <h2 className="text-2xl font-bold leading-7 text-gray-900 dark:text-white sm:truncate sm:text-3xl sm:tracking-tight">
          Upload New Asset Batch
        </h2>
        <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
          Upload assets and attach them to an existing dataset to distribute tasks.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="bg-white dark:bg-gray-900 shadow-sm ring-1 ring-gray-900/5 sm:rounded-2xl md:col-span-2 border border-gray-100 dark:border-gray-800">
        <div className="px-4 py-6 sm:p-8">
          <div className="grid max-w-2xl grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6 mb-8">
            <div className="col-span-full">
              <label htmlFor="name" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Asset Name
              </label>
              <div className="mt-2">
                <input
                  type="text"
                  name="name"
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
                />
              </div>
            </div>

            <div className="col-span-full">
              <label htmlFor="description" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Description
              </label>
              <div className="mt-2">
                <textarea
                  id="description"
                  name="description"
                  rows={2}
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
                />
              </div>
            </div>

            <div className="sm:col-span-3">
              <label htmlFor="dataset_id" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Linked Dataset
              </label>
              <div className="mt-2">
                <select
                  id="dataset_id"
                  name="dataset_id"
                  value={formData.dataset_id}
                  disabled={datasetsLoading}
                  onChange={(e) => setFormData({ ...formData, dataset_id: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:max-w-xs sm:text-sm sm:leading-6 disabled:opacity-50"
                >
                  <option value="" disabled>{datasetsLoading ? "Loading datasets..." : "Select a dataset..."}</option>
                  {datasets.map(d => <option key={d.id} value={d.id}>{d.name} ({d.id})</option>)}
                </select>
              </div>
            </div>

            <div className="sm:col-span-3">
              <label htmlFor="tags" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Tags (comma separated)
              </label>
              <div className="mt-2">
                <input
                  type="text"
                  name="tags"
                  id="tags"
                  value={formData.tags}
                  onChange={(e) => setFormData({ ...formData, tags: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
                  placeholder="medical, batch-1, priority"
                />
              </div>
            </div>
          </div>

          <div className="mt-10 border-t border-gray-900/10 dark:border-gray-800 pt-8">
              <div className="flex justify-between items-center mb-4">
                  <h3 className="text-lg font-medium text-gray-900 dark:text-white">Annotation Fields</h3>
                  <button type="button" onClick={() => setAnnotateFields([...annotateFields, { name: "", description: "", modality: "text" }])} className="text-sm font-semibold text-blue-600 hover:text-blue-500 flex items-center gap-1">
                      <Plus className="w-4 h-4"/> Add Field
                  </button>
              </div>
              <div className="space-y-4">
                  {annotateFields.map((field, idx) => (
                      <div key={idx} className="flex gap-4 items-start p-4 bg-gray-50 dark:bg-gray-800/50 rounded-xl border border-gray-200 dark:border-gray-700">
                          <div className="flex-1 space-y-4">
                            <input
                                placeholder="Field Name (e.g., label_category)"
                                value={field.name}
                                onChange={(e) => { const newF = [...annotateFields]; newF[idx].name = e.target.value; setAnnotateFields(newF); }}
                                className="block w-full rounded-lg border-0 py-2 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-600 focus:ring-2 sm:text-sm"
                            />
                            <input
                                placeholder="Description (instructions for the annotator)"
                                value={field.description}
                                onChange={(e) => { const newF = [...annotateFields]; newF[idx].description = e.target.value; setAnnotateFields(newF); }}
                                className="block w-full rounded-lg border-0 py-2 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-600 focus:ring-2 sm:text-sm"
                            />
                          </div>
                          <select
                                value={field.modality}
                                onChange={(e) => { const newF = [...annotateFields]; newF[idx].modality = e.target.value; setAnnotateFields(newF); }}
                                className="block rounded-lg border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-600 focus:ring-2 sm:text-sm"
                            >
                                <option value="text">Text</option>
                                <option value="image">Image</option>
                                <option value="audio">Audio</option>
                                <option value="video">Video</option>
                            </select>
                            <button type="button" onClick={() => setAnnotateFields(annotateFields.filter((_, i) => i !== idx))} className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg transition-colors">
                                <Trash2 className="w-5 h-5"/>
                            </button>
                      </div>
                  ))}
              </div>
          </div>

        </div>
        {error && (
          <div className="px-4 py-3 bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 text-sm border-t border-red-200 dark:border-red-900/50">
            {error}
          </div>
        )}
        <div className="flex items-center justify-end gap-x-6 border-t border-gray-900/10 dark:border-gray-800 px-4 py-4 sm:px-8">
          <button
            type="button"
            onClick={() => router.back()}
            className="text-sm font-semibold leading-6 text-gray-900 dark:text-white hover:text-gray-700 transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading}
            className="rounded-xl bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Uploading..." : "Upload & Distribute"}
          </button>
        </div>
      </form>
    </div>
  );
}
