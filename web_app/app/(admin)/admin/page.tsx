"use client";

import { useQuery } from "@tanstack/react-query";
import { Database, FolderArchive, Users, Activity } from "lucide-react";
import { DatasetsRepository } from "@/lib/repositories/datasets";
import { AssetsRepository } from "@/lib/repositories/assets";
import Link from "next/link";

export default function AdminPage() {
  const { data: datasets, isPending: datasetsLoading } = useQuery({
    queryKey: ['datasets'],
    queryFn: () => DatasetsRepository.listDatasets(),
  });

  const { data: assets, isPending: assetsLoading } = useQuery({
    queryKey: ['assets', 'adminAll'],
    queryFn: () => AssetsRepository.listAssets(undefined, true),
  });

  const stats = [
    { 
      name: "Total Datasets", 
      stat: datasetsLoading ? "..." : datasets?.length?.toString() || "0", 
      icon: Database, 
      link: "/admin/datasets" 
    },
    { 
      name: "Total Assets", 
      stat: assetsLoading ? "..." : assets?.length?.toString() || "0", 
      icon: FolderArchive, 
      link: "/admin/assets" 
    },
    { 
      name: "Active Users", 
      stat: "N/A", 
      icon: Users, 
      link: "#" 
    },
    { 
      name: "System Health", 
      stat: "Optimal", 
      icon: Activity, 
      link: "#" 
    },
  ];

  return (
    <div className="space-y-6">
      <div className="sm:flex sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold leading-7 text-gray-900 dark:text-white sm:truncate sm:text-3xl sm:tracking-tight">
          Dashboard Overview
        </h1>
      </div>

      <dl className="mt-5 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((item) => (
          <div
            key={item.name}
            className="relative overflow-hidden rounded-2xl bg-white dark:bg-gray-900 px-4 pb-12 pt-5 shadow-sm sm:px-6 sm:pt-6 border border-gray-100 dark:border-gray-800 hover:shadow-md transition-shadow"
          >
            <dt>
              <div className="absolute rounded-xl bg-blue-50 dark:bg-blue-900/30 p-3">
                <item.icon className="h-6 w-6 text-blue-600 dark:text-blue-400" aria-hidden="true" />
              </div>
              <p className="ml-16 truncate text-sm font-medium text-gray-500 dark:text-gray-400">{item.name}</p>
            </dt>
            <dd className="ml-16 flex items-baseline pb-6 sm:pb-7">
              <p className="text-2xl font-semibold text-gray-900 dark:text-white">{item.stat}</p>
              
              <div className="absolute inset-x-0 bottom-0 bg-gray-50 dark:bg-gray-800/50 px-4 py-4 sm:px-6 border-t border-gray-100 dark:border-gray-800 transition-colors hover:bg-gray-100 dark:hover:bg-gray-800">
                <div className="text-sm">
                  <Link href={item.link} className="font-medium text-blue-600 dark:text-blue-400 hover:text-blue-500">
                    View details<span className="sr-only"> {item.name} stats</span>
                  </Link>
                </div>
              </div>
            </dd>
          </div>
        ))}
      </dl>
    </div>
  );
}
