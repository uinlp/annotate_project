"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { DatasetsRepository } from "@/lib/repositories/datasets";
import { DatasetCreateModelSchema } from "@/lib/models/datasets";
import { UploadCloud } from "lucide-react";

export default function CreateDatasetPage() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState<number | null>(null);
  
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    modality: "text",
    batch_size: "100",
  });
  
  const [file, setFile] = useState<File | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    setUploadProgress(null);
    
    if (!file) {
      setError("Please select a valid .zip dataset file to upload.");
      setLoading(false);
      return;
    }

    try {
      // 1. Validate form data
      const parsedData = DatasetCreateModelSchema.parse({
        ...formData,
        batch_size: parseInt(formData.batch_size, 10) || 1,
      });

      // 2. Request an S3 Presigned URL from Backend
      setUploadProgress(10);
      const urlResponse = await DatasetsRepository.createDataset(parsedData);
      
      // 3. Upload the Zip File to S3 Directly
      setUploadProgress(40);
      const uploadRes = await fetch(urlResponse.url, {
        method: "PUT",
        body: file,
        headers: {
          "Content-Type": "application/zip",
        },
      });

      if (!uploadRes.ok) {
        throw new Error("Failed to upload the dataset file to S3 securely.");
      }
      setUploadProgress(100);

      // 4. Return to Dashboard
      router.push("/admin/datasets");
      router.refresh();
      
    } catch (err: any) {
      console.error(err);
      if (err.errors) {
        setError(err.errors[0].message);
      } else {
        setError(err.message || "An error occurred during dataset creation.");
      }
    } finally {
      if (!uploadProgress || uploadProgress !== 100) setLoading(false);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const selectedFile = e.target.files[0];
      if (!selectedFile.name.endsWith(".zip")) {
        setError("Only .zip files are supported for dataset uploads.");
        setFile(null);
      } else {
        setError(null);
        setFile(selectedFile);
      }
    }
  };

  return (
    <div className="max-w-3xl mx-auto space-y-8 py-8">
      <div>
        <h2 className="text-2xl font-bold leading-7 text-gray-900 dark:text-white sm:truncate sm:text-3xl sm:tracking-tight">
          Establish New Dataset
        </h2>
        <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
          Set up a new dataset to organize tasks and manage uploaded assets efficiently.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="bg-white dark:bg-gray-900 shadow-sm ring-1 ring-gray-900/5 sm:rounded-2xl md:col-span-2 border border-gray-100 dark:border-gray-800">
        <div className="px-4 py-6 sm:p-8">
          <div className="grid max-w-2xl grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6 mb-8">
            <div className="col-span-full">
              <label htmlFor="name" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Dataset Name
              </label>
              <div className="mt-2">
                <input
                  type="text"
                  name="name"
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
                  placeholder="e.g., Medical Image Annotations"
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
                  rows={3}
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
                  placeholder="A brief explanation of this dataset's purpose..."
                />
              </div>
            </div>

            <div className="sm:col-span-3">
              <label htmlFor="modality" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Modality
              </label>
              <div className="mt-2">
                <select
                  id="modality"
                  name="modality"
                  value={formData.modality}
                  onChange={(e) => setFormData({ ...formData, modality: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:max-w-xs sm:text-sm sm:leading-6"
                >
                  <option value="text">Text</option>
                  <option value="image">Image</option>
                  <option value="audio">Audio</option>
                  <option value="video">Video</option>
                </select>
              </div>
            </div>

            <div className="sm:col-span-3">
              <label htmlFor="batch_size" className="block text-sm font-medium leading-6 text-gray-900 dark:text-white">
                Batch Size
              </label>
              <div className="mt-2">
                <input
                  type="number"
                  name="batch_size"
                  id="batch_size"
                  value={formData.batch_size}
                  onChange={(e) => setFormData({ ...formData, batch_size: e.target.value })}
                  className="block w-full rounded-xl border-0 py-2.5 px-3 text-gray-900 dark:text-white dark:bg-black/20 shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:max-w-xs sm:text-sm sm:leading-6"
                  placeholder="50"
                  min="1"
                />
              </div>
            </div>
            
            <div className="col-span-full">
                <label className="block text-sm font-medium leading-6 text-gray-900 dark:text-white mb-2">Dataset Source Archive (.zip)</label>
                <div className="mt-2 flex justify-center rounded-xl border border-dashed border-gray-300 dark:border-gray-700 px-6 py-10 hover:border-blue-500 hover:bg-blue-50/50 dark:hover:bg-blue-900/10 transition-colors cursor-pointer group relative">
                    <input
                        type="file"
                        accept=".zip"
                        onChange={handleFileChange}
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                    />
                    <div className="text-center">
                        <UploadCloud className="mx-auto h-10 w-10 text-gray-300 group-hover:text-blue-500 transition-colors" aria-hidden="true" />
                        <div className="mt-4 flex text-sm leading-6 text-gray-600 dark:text-gray-400">
                            {file ? (
                                <p className="font-semibold text-blue-600 dark:text-blue-400">Selected: {file.name} ({Math.round(file.size / 1024 / 1024)} mb)</p>
                            ) : (
                                <p>Click to browse or drag and drop your .zip package here</p>
                            )}
                        </div>
                    </div>
                </div>
            </div>
          </div>
        </div>

        {uploadProgress !== null && (
          <div className="px-8 pb-6">
              <div className="w-full bg-gray-200 dark:bg-gray-800 rounded-full h-2.5 mb-2">
                <div className="bg-blue-600 h-2.5 rounded-full transition-all duration-300" style={{ width: `${uploadProgress}%` }}></div>
              </div>
              <p className="text-xs text-gray-500 text-center font-medium">Uploading securely to S3... {uploadProgress}%</p>
          </div>
        )}

        {error && (
          <div className="px-4 py-3 bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 text-sm border-t border-red-200 dark:border-red-900/50">
            {error}
          </div>
        )}

        <div className="flex items-center justify-end gap-x-6 border-t border-gray-900/10 dark:border-gray-800 px-4 py-4 sm:px-8">
          <button
            type="button"
            onClick={() => router.back()}
            disabled={loading}
            className="text-sm font-semibold leading-6 text-gray-900 dark:text-white hover:text-gray-700 transition-colors disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading}
            className="rounded-xl bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Uploading..." : "Save & Upload Dataset"}
          </button>
        </div>
      </form>
    </div>
  );
}
