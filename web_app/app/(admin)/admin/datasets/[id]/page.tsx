"use client";

import { useQuery } from "@tanstack/react-query";
import { DatasetsRepository } from "@/lib/repositories/datasets";
import { Database, Trash2, Calendar, FileText, Activity } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { use, useState } from "react";

export default function DatasetDetailsPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const router = useRouter();
  const [isDeleting, setIsDeleting] = useState(false);

  const { data: dataset, isPending, isError } = useQuery({
    queryKey: ['dataset', id],
    queryFn: () => DatasetsRepository.getDataset(id),
  });

  const handleDelete = async () => {
    if (!confirm("Are you sure you want to delete this dataset? This action maps an internal soft deletion.")) return;
    setIsDeleting(true);
    try {
      await DatasetsRepository.deleteDataset(id);
      router.push("/admin/datasets");
      router.refresh();
    } catch (err) {
      console.error("Failed to delete dataset:", err);
      alert("Failed to securely delete this dataset.");
      setIsDeleting(false);
    }
  };

  if (isPending) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (isError || !dataset) {
    return (
      <div className="rounded-xl border border-red-200 bg-red-50 p-4 dark:border-red-900/50 dark:bg-red-900/20">
        <p className="text-sm text-red-600 dark:text-red-400">Failed to load dataset metadata.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-5xl mx-auto">
      <div className="sm:flex sm:items-center sm:justify-between border-b border-gray-200 dark:border-gray-800 pb-5">
        <div className="flex items-center gap-4">
            <Link href="/admin/datasets" className="text-sm font-medium text-gray-500 hover:text-gray-900 dark:hover:text-white transition-colors">
                &larr; Back to Datasets
            </Link>
            <h3 className="text-2xl font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-3">
            <Database className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            {dataset.name}
            </h3>
        </div>
        <div className="mt-4 sm:mt-0">
            <button
                onClick={handleDelete}
                disabled={isDeleting}
                className="inline-flex items-center gap-2 rounded-xl bg-red-50 dark:bg-red-900/20 px-3 py-2 text-sm font-semibold text-red-600 dark:text-red-400 hover:bg-red-100 dark:hover:bg-red-900/40 transition-colors disabled:opacity-50"
            >
                <Trash2 className="w-4 h-4" />
                {isDeleting ? "Deleting..." : "Delete Dataset"}
            </button>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
              {/* Primary Descriptions */}
              <div className="bg-white dark:bg-gray-900 overflow-hidden shadow-sm rounded-2xl border border-gray-100 dark:border-gray-800">
                  <div className="px-4 py-5 sm:px-6 border-b border-gray-100 dark:border-gray-800">
                      <h3 className="text-base font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-2">
                          <FileText className="w-5 h-5 text-gray-400" /> General Info
                      </h3>
                  </div>
                  <div className="px-4 py-5 sm:p-6 space-y-4">
                      <div>
                          <p className="text-sm font-medium text-gray-500">Description</p>
                          <p className="mt-1 text-base text-gray-900 dark:text-gray-300">{dataset.description}</p>
                      </div>
                      
                      <div className="pt-4 border-t border-gray-100 dark:border-gray-800">
                          <p className="text-sm font-medium text-gray-500 mb-2">Processing Status</p>
                          {dataset.is_completed ? (
                              <span className="inline-flex items-center gap-1.5 rounded-md bg-green-50 dark:bg-green-900/30 px-2 py-1 text-sm font-medium text-green-700 dark:text-green-400 ring-1 ring-inset ring-green-600/20">
                                  <div className="w-1.5 h-1.5 rounded-full bg-green-500" />
                                  Completed & Processed
                              </span>
                          ) : (
                              <span className="inline-flex items-center gap-1.5 rounded-md bg-yellow-50 dark:bg-yellow-900/30 px-2 py-1 text-sm font-medium text-yellow-800 dark:text-yellow-500 ring-1 ring-inset ring-yellow-600/20">
                                  <div className="w-1.5 h-1.5 rounded-full bg-yellow-500 animate-pulse" />
                                  Processing Media Batches...
                              </span>
                          )}
                      </div>
                  </div>
              </div>
          </div>

          <div className="space-y-6">
              {/* Properties Box */}
              <div className="bg-white dark:bg-gray-900 overflow-hidden shadow-sm rounded-2xl border border-gray-100 dark:border-gray-800">
                  <div className="px-4 py-5 sm:px-6 border-b border-gray-100 dark:border-gray-800">
                      <h3 className="text-base font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-2">
                          <Activity className="w-5 h-5 text-gray-400" /> Dataset Properties
                      </h3>
                  </div>
                  <div className="px-4 py-5 sm:p-6 space-y-4">
                      <div>
                          <p className="text-sm font-medium text-gray-500">Modality Type</p>
                          <span className="mt-1 inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10 dark:bg-blue-900/30 dark:text-blue-400 dark:ring-blue-400/20">
                            {dataset.modality.toUpperCase()}
                          </span>
                      </div>
                      <div>
                          <p className="text-sm font-medium text-gray-500 mt-4">Calculated Batch Size</p>
                          <p className="mt-1 font-mono text-sm text-gray-900 dark:text-gray-300">{dataset.batch_size} files per batch</p>
                      </div>
                      <div>
                          <p className="text-sm font-medium text-gray-500 mt-4">Total Generated Batches</p>
                          <p className="mt-1 font-mono text-sm text-gray-900 dark:text-gray-300">{dataset.batch_keys ? dataset.batch_keys.length : 0} active batches</p>
                      </div>
                      <div className="pt-4 mt-4 border-t border-gray-100 dark:border-gray-800">
                          <p className="text-xs font-medium text-gray-500 flex items-center gap-2"><Calendar className="w-3 h-3"/> Created On</p>
                          <p className="mt-1 text-xs text-gray-500">{new Date(dataset.created_at).toLocaleString()}</p>
                      </div>
                  </div>
              </div>
          </div>
      </div>
    </div>
  );
}
