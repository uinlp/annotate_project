import Link from "next/link";
import {
  Brain,
  Database,
  FolderArchive,
  Smartphone,
  Zap,
  ShieldCheck,
  Globe2,
  ArrowRight,
  FileText,
  Image,
  Mic,
  Video,
} from "lucide-react";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#050814] text-white overflow-x-hidden">

      {/* Ambient background orbs */}
      <div className="pointer-events-none fixed inset-0 z-0">
        <div className="absolute -top-40 -left-40 h-[600px] w-[600px] rounded-full bg-purple-600/20 blur-[120px]" />
        <div className="absolute top-1/3 right-[-200px] h-[500px] w-[500px] rounded-full bg-blue-600/20 blur-[120px]" />
        <div className="absolute bottom-0 left-1/3 h-[400px] w-[400px] rounded-full bg-indigo-600/15 blur-[100px]" />
      </div>

      {/* ─── Header ─── */}
      <header className="relative z-10 sticky top-0 border-b border-white/5 bg-[#050814]/80 backdrop-blur-xl">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-2.5">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-purple-500 to-blue-600 shadow-lg shadow-purple-500/30">
              <Brain className="h-4 w-4 text-white" />
            </div>
            <span className="text-lg font-bold tracking-tight bg-gradient-to-r from-purple-300 via-blue-300 to-indigo-300 bg-clip-text text-transparent">
              UINLP
            </span>
          </div>
          <Link
            href="/admin"
            className="group inline-flex items-center gap-2 rounded-full bg-white/5 border border-white/10 px-4 py-2 text-sm font-medium text-gray-300 transition-all hover:bg-white/10 hover:text-white"
          >
            Admin Dashboard
            <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
          </Link>
        </div>
      </header>

      {/* ─── Hero ─── */}
      <section className="relative z-10 mx-auto max-w-7xl px-6 pt-28 pb-24 text-center">
        <div className="mx-auto max-w-3xl">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-purple-500/30 bg-purple-500/10 px-4 py-1.5 text-xs font-medium text-purple-300">
            <Zap className="h-3 w-3" />
            Multi-Modal Annotation at Scale
          </div>

          <h1 className="mb-6 text-5xl sm:text-6xl font-extrabold leading-tight tracking-tight">
            Power Your AI{" "}
            <span className="bg-gradient-to-r from-purple-400 via-blue-400 to-indigo-400 bg-clip-text text-transparent">
              with Flawless Data
            </span>
          </h1>

          <p className="mx-auto mb-10 max-w-xl text-lg leading-8 text-gray-400">
            UINLP connects data teams with annotators worldwide, enabling structured collection, labeling, and distribution of text, image, audio, and video tasks — all from one unified platform.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link
              href="/admin"
              className="group relative inline-flex items-center gap-2 rounded-full bg-gradient-to-r from-purple-600 to-blue-600 px-7 py-3.5 text-sm font-semibold text-white shadow-xl shadow-purple-500/25 transition-all hover:shadow-purple-500/40 hover:scale-105 active:scale-100"
            >
              Access Admin Dashboard
              <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
            </Link>
            <a
              href="#features"
              className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-7 py-3.5 text-sm font-semibold text-gray-300 transition-all hover:bg-white/10 hover:text-white"
            >
              Explore Features
            </a>
          </div>
        </div>

        {/* Stat chips */}
        <div className="mt-20 flex flex-wrap items-center justify-center gap-4">
          {[
            { label: "Multi-Modal Tasks", value: "4 types" },
            { label: "Batch Automation", value: "S3-backed" },
            { label: "Annotator-Ready", value: "Mobile App" },
            { label: "Data Security", value: "AWS Cognito" },
          ].map((stat) => (
            <div
              key={stat.label}
              className="rounded-2xl border border-white/8 bg-white/4 px-6 py-4 text-left backdrop-blur-sm"
            >
              <p className="text-xl font-bold text-white">{stat.value}</p>
              <p className="mt-0.5 text-xs text-gray-500">{stat.label}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ─── Modalities ─── */}
      <section id="features" className="relative z-10 mx-auto max-w-7xl px-6 pb-24">
        <div className="mb-14 text-center">
          <h2 className="text-3xl font-bold tracking-tight">
            Annotate Every{" "}
            <span className="bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
              Modality
            </span>
          </h2>
          <p className="mt-3 text-gray-400">
            Purpose-built for complex, multi-modal annotation pipelines.
          </p>
        </div>

        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {[
            {
              icon: FileText,
              title: "Text",
              desc: "Classification, NER, sentiment, translation and Q&A annotation tasks.",
              color: "from-blue-500 to-blue-700",
              glow: "shadow-blue-500/20",
            },
            {
              icon: Image,
              title: "Image",
              desc: "Bounding boxes, segmentation masks, and visual question answering.",
              color: "from-purple-500 to-purple-700",
              glow: "shadow-purple-500/20",
            },
            {
              icon: Mic,
              title: "Audio",
              desc: "Transcription, speaker diarisation, and acoustic event labelling.",
              color: "from-pink-500 to-pink-700",
              glow: "shadow-pink-500/20",
            },
            {
              icon: Video,
              title: "Video",
              desc: "Temporal segment annotation, action recognition, and captioning.",
              color: "from-indigo-500 to-indigo-700",
              glow: "shadow-indigo-500/20",
            },
          ].map(({ icon: Icon, title, desc, color, glow }) => (
            <div
              key={title}
              className="group relative rounded-2xl border border-white/8 bg-white/4 p-6 backdrop-blur-sm transition-all hover:-translate-y-1 hover:border-white/15 hover:bg-white/6"
            >
              <div
                className={`mb-5 flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br ${color} shadow-lg ${glow}`}
              >
                <Icon className="h-5 w-5 text-white" />
              </div>
              <h3 className="mb-2 font-semibold text-white">{title}</h3>
              <p className="text-sm leading-relaxed text-gray-500">{desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ─── Platform Features ─── */}
      <section className="relative z-10 mx-auto max-w-7xl px-6 pb-28">
        <div className="grid gap-5 md:grid-cols-3">
          {[
            {
              icon: Database,
              title: "Automated Batch Distribution",
              desc: "Upload a dataset archive and the platform automatically chunks, packages, and distributes annotated batches to S3.",
            },
            {
              icon: Smartphone,
              title: "Offline-First Mobile App",
              desc: "Annotators work on tasks via a dedicated Flutter app, enabling collections even in low-connectivity regions.",
            },
            {
              icon: ShieldCheck,
              title: "Secure by Default",
              desc: "All authentication is managed by Amazon Cognito. Data transfers use presigned S3 URLs with short TTLs.",
            },
            {
              icon: FolderArchive,
              title: "Asset Management",
              desc: "Group annotation batches into assets with custom fields, tags, and modality settings.",
            },
            {
              icon: Zap,
              title: "Real-Time Admin Dashboard",
              desc: "Monitor dataset processing status, browse assets, and download completed annotation packages instantly.",
            },
            {
              icon: Globe2,
              title: "Cloud Native Infrastructure",
              desc: "Deployed on AWS with Terraform-managed DynamoDB, S3, Lambda and API Gateway — fully scalable.",
            },
          ].map(({ icon: Icon, title, desc }) => (
            <div
              key={title}
              className="group rounded-2xl border border-white/8 bg-white/4 p-7 backdrop-blur-sm transition-all hover:-translate-y-1 hover:border-white/15"
            >
              <Icon className="mb-4 h-6 w-6 text-purple-400" />
              <h3 className="mb-2 font-semibold text-white">{title}</h3>
              <p className="text-sm leading-relaxed text-gray-500">{desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ─── CTA Banner ─── */}
      <section className="relative z-10 mx-auto max-w-7xl px-6 pb-28">
        <div className="relative overflow-hidden rounded-3xl border border-purple-500/20 bg-gradient-to-br from-purple-900/40 to-blue-900/40 px-8 py-16 text-center backdrop-blur-sm">
          <div className="pointer-events-none absolute inset-0">
            <div className="absolute -top-20 left-1/2 h-60 w-60 -translate-x-1/2 rounded-full bg-purple-600/30 blur-[80px]" />
          </div>
          <h2 className="relative mb-4 text-3xl font-bold tracking-tight">
            Ready to build your annotation pipeline?
          </h2>
          <p className="relative mx-auto mb-8 max-w-md text-gray-400">
            Sign in with your team credentials and start structuring your datasets today.
          </p>
          <Link
            href="/admin"
            className="inline-flex items-center gap-2 rounded-full bg-gradient-to-r from-purple-600 to-blue-600 px-8 py-3.5 text-sm font-semibold text-white shadow-xl shadow-purple-500/30 transition-all hover:scale-105 active:scale-100"
          >
            Get Started <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </section>

      {/* ─── Footer ─── */}
      <footer className="relative z-10 border-t border-white/5">
        <div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 px-6 py-8 sm:flex-row">
          <div className="flex items-center gap-2.5">
            <div className="flex h-6 w-6 items-center justify-center rounded-md bg-gradient-to-br from-purple-500 to-blue-600">
              <Brain className="h-3.5 w-3.5 text-white" />
            </div>
            <span className="text-sm font-semibold text-gray-400">UINLP</span>
          </div>
          <p className="text-xs text-gray-600">
            &copy; {new Date().getFullYear()} UINLP. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
