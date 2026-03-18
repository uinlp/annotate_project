"use client";

import { useQuery } from "@tanstack/react-query";
import { AssetsRepository } from "@/lib/repositories/assets";
import { FolderArchive, Download, Share, UserCircle, Calendar, Tag, HardDrive } from "lucide-react";
import Link from "next/link";
import { use } from "react";

export default function AssetDetailsPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);

  const { data: asset, isPending: assetLoading, isError: assetError } = useQuery({
    queryKey: ['asset', id],
    queryFn: () => AssetsRepository.getAsset(id),
  });

  const { data: publishes = [], isPending: publishesLoading } = useQuery({
    queryKey: ['publishes', id],
    queryFn: () => AssetsRepository.listPublishes(id),
  });

  const handleDownload = async (publisherId: string) => {
    try {
      const { url } = await AssetsRepository.createPublishDownloadUrl(id, publisherId);
      window.open(url, '_blank');
    } catch (error) {
      console.error("Failed to fetch download url:", error);
      alert("Failed to initiate download.");
    }
  };

  if (assetLoading) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (assetError || !asset) {
    return (
      <div className="rounded-xl border border-red-200 bg-red-50 p-4 dark:border-red-900/50 dark:bg-red-900/20">
        <p className="text-sm text-red-600 dark:text-red-400">Failed to load asset details.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-5xl mx-auto">
      <div className="sm:flex sm:items-center sm:justify-between border-b border-gray-200 dark:border-gray-800 pb-5">
        <div className="flex items-center gap-4">
            <Link href="/admin/assets" className="text-sm font-medium text-gray-500 hover:text-gray-900 dark:hover:text-white transition-colors">
                &larr; Back to Assets
            </Link>
            <h3 className="text-2xl font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-3">
            <FolderArchive className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            {asset.name}
            </h3>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
              {/* Publishers List */}
              <div className="bg-white dark:bg-gray-900 overflow-hidden shadow-sm rounded-2xl border border-gray-100 dark:border-gray-800">
                <div className="px-4 py-5 sm:px-6 border-b border-gray-100 dark:border-gray-800 flex justify-between items-center">
                    <div>
                        <h3 className="text-base font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-2">
                            <Share className="w-5 h-5 text-gray-400" /> Annotator Publishes
                        </h3>
                        <p className="mt-1 max-w-2xl text-sm text-gray-500">All effectively completed annotations tied to this asset schema.</p>
                    </div>
                    <span className="inline-flex items-center rounded-full bg-blue-50 dark:bg-blue-900/30 px-2.5 py-0.5 text-xs font-medium text-blue-700 dark:text-blue-400 ring-1 ring-inset ring-blue-700/10 dark:ring-blue-400/20">
                        Total: {publishes.length}
                    </span>
                </div>
                {publishesLoading ? (
                    <div className="p-8 text-center text-sm text-gray-500 flex justify-center">
                        <div className="h-6 w-6 animate-spin rounded-full border-b-2 border-gray-400"></div>
                    </div>
                ) : publishes.length === 0 ? (
                    <div className="p-12 text-center text-sm text-gray-500">
                        <Share className="mx-auto h-12 w-12 text-gray-300 dark:text-gray-700 mb-4" />
                        <p className="text-lg font-medium text-gray-900 dark:text-white">No publishes available yet.</p>
                        <p className="mt-1">Tasks have not been completed and published by any annotators.</p>
                    </div>
                ) : (
                    <ul role="list" className="divide-y divide-gray-100 dark:divide-gray-800">
                        {publishes.map((publish) => (
                            <li key={publish.publish_key} className="flex items-center justify-between gap-x-6 py-5 px-6 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
                                <div className="min-w-0">
                                    <div className="flex items-start gap-x-3">
                                        <p className="text-sm font-semibold leading-6 text-gray-900 dark:text-white flex items-center gap-2">
                                            <UserCircle className="w-4 h-4 text-gray-400" />
                                            Publisher: <span className="font-mono bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded">{publish.publisher_id}</span>
                                        </p>
                                    </div>
                                    <div className="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
                                        <p className="whitespace-nowrap flex items-center gap-1">
                                            <Calendar className="w-3 h-3" />
                                            Published: {new Date(publish.created_at).toLocaleDateString()}
                                        </p>
                                        <svg viewBox="0 0 2 2" className="h-0.5 w-0.5 fill-current"><circle cx={1} cy={1} r={1} /></svg>
                                        <p className="truncate">Key: {publish.publish_key}</p>
                                    </div>
                                </div>
                                <div className="flex flex-none items-center gap-x-4">
                                    <button
                                        onClick={() => handleDownload(publish.publisher_id)}
                                        className="hidden sm:flex items-center gap-2 rounded-lg bg-white dark:bg-gray-800 px-3 py-2 text-sm font-semibold text-gray-900 dark:text-white shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition-all active:scale-95"
                                    >
                                        <Download className="w-4 h-4" /> Download ZIP
                                    </button>
                                </div>
                            </li>
                        ))}
                    </ul>
                )}
              </div>
          </div>

          <div className="space-y-6">
              {/* Asset Metadata */}
              <div className="bg-white dark:bg-gray-900 overflow-hidden shadow-sm rounded-2xl border border-gray-100 dark:border-gray-800">
                  <div className="px-4 py-5 sm:px-6 border-b border-gray-100 dark:border-gray-800">
                      <h3 className="text-base font-semibold leading-6 text-gray-900 dark:text-white">Metadata</h3>
                  </div>
                  <div className="px-4 py-5 sm:p-6 space-y-4">
                      <div>
                          <p className="text-sm font-medium text-gray-500">Description</p>
                          <p className="mt-1 text-sm text-gray-900 dark:text-white">{asset.description}</p>
                      </div>
                      <div>
                          <p className="text-sm font-medium text-gray-500 flex items-center gap-2 mt-4"><HardDrive className="w-4 h-4"/> Target Dataset</p>
                          <p className="mt-1 font-mono text-xs bg-gray-100 dark:bg-gray-800 p-2 rounded text-gray-900 dark:text-gray-300">{asset.dataset_id}</p>
                      </div>
                      <div>
                          <p className="text-sm font-medium text-gray-500 mt-4">Modality Filter</p>
                          <span className="mt-1 inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10 dark:bg-blue-900/30 dark:text-blue-400 dark:ring-blue-400/20">
                            {asset.modality.toUpperCase()}
                          </span>
                      </div>
                      {asset.tags && asset.tags.length > 0 && (
                          <div>
                              <p className="text-sm font-medium text-gray-500 flex items-center gap-2 mt-4"><Tag className="w-4 h-4"/> Tags</p>
                              <div className="mt-2 flex flex-wrap gap-2">
                                  {asset.tags.map(tag => (
                                      <span key={tag} className="inline-flex items-center rounded-md bg-gray-50 dark:bg-gray-800 px-2 py-1 text-xs font-medium text-gray-600 dark:text-gray-300 ring-1 ring-inset ring-gray-500/10 dark:ring-gray-700">
                                          {tag}
                                      </span>
                                  ))}
                              </div>
                          </div>
                      )}
                  </div>
              </div>
          </div>
      </div>
    </div>
  );
}
