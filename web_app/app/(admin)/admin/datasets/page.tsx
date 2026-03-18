"use client";

import { useEffect, useState } from "react";
import { DatasetsRepository } from "@/lib/repositories/datasets";
import { Database, Plus } from "lucide-react";
import Link from "next/link";
import { DatasetModel } from "@/lib/models/datasets";

export default function DatasetsPage() {
  const [datasets, setDatasets] = useState<DatasetModel[]>([]);
  const [fetchError, setFetchError] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    DatasetsRepository.listDatasets()
      .then((data) => {
        setDatasets(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setFetchError(true);
        setLoading(false);
      });
  }, []);

  if (loading) {
      return (
          <div className="flex h-[50vh] items-center justify-center">
              <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-blue-600"></div>
          </div>
      );
  }

  return (
    <div className="space-y-6">
      <div className="sm:flex sm:items-center sm:justify-between border-b border-gray-200 dark:border-gray-800 pb-5">
        <h3 className="text-2xl font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-3">
          <Database className="h-6 w-6 text-blue-600 dark:text-blue-400" />
          Datasets
        </h3>
        <div className="mt-3 sm:ml-4 sm:mt-0">
          <Link
            href="/admin/datasets/create"
            className="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 transition-all active:scale-95"
          >
            <Plus className="w-5 h-5 -ml-1" /> Create new dataset
          </Link>
        </div>
      </div>
      
      {fetchError && (
        <div className="rounded-xl border border-red-200 bg-red-50 p-4 dark:border-red-900/50 dark:bg-red-900/20">
            <p className="text-sm text-red-600 dark:text-red-400">Failed to connect to the backend APIs. Are you authenticated?</p>
        </div>
      )}

      {!fetchError && datasets.length === 0 ? (
        <div className="rounded-2xl bg-white dark:bg-gray-900 shadow-sm border border-gray-100 dark:border-gray-800 overflow-hidden">
          <div className="px-4 py-16 sm:p-16 text-center text-gray-500 dark:text-gray-400">
            <Database className="mx-auto h-12 w-12 text-gray-300 dark:text-gray-600 mb-4" />
            <p className="text-lg font-medium text-gray-900 dark:text-white">No datasets found</p>
            <p className="mt-1">Create your first dataset to get started.</p>
          </div>
        </div>
      ) : (
        <div className="overflow-hidden rounded-2xl bg-white dark:bg-gray-900 shadow-sm border border-gray-100 dark:border-gray-800">
          <ul role="list" className="divide-y divide-gray-100 dark:divide-gray-800">
            {datasets.map((dataset) => (
              <li key={dataset.id} className="relative flex justify-between gap-x-6 px-4 py-5 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors sm:px-6">
                <div className="flex min-w-0 gap-x-4">
                  <div className="min-w-0 flex-auto">
                    <p className="text-sm font-semibold leading-6 text-gray-900 dark:text-white">
                      <Link href={`/admin/datasets/${dataset.id}`}>
                        <span className="absolute inset-x-0 -top-px bottom-0" />
                        {dataset.name}
                      </Link>
                    </p>
                    <p className="mt-1 flex text-xs leading-5 text-gray-500 dark:text-gray-400 line-clamp-1">
                      {dataset.description}
                    </p>
                  </div>
                </div>
                <div className="flex shrink-0 items-center gap-x-4 z-10">
                  <span className="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10 dark:bg-blue-900/30 dark:text-blue-400 dark:ring-blue-400/20">
                    {dataset.modality}
                  </span>
                  <div className="hidden sm:flex sm:flex-col sm:items-end">
                    <p className="text-sm leading-6 text-gray-900 dark:text-white">Batch Size: {dataset.batch_size}</p>
                    <p className="mt-1 text-xs leading-5 text-gray-500 dark:text-gray-400">
                        {new Date(dataset.created_at).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
