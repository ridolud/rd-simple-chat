// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2024-04-03",
  devtools: { enabled: true },
  future: {
    compatibilityVersion: 4,
  },
  modules: ["@nuxt/ui", "@nuxtjs/supabase", "@vueuse/nuxt", "@pinia/nuxt"],
  imports: {
    dirs: ["./app/stores/**", "./app/types/database.ts"],
  },
  supabase: {
    redirectOptions: {
      login: "/auth/login",
      callback: "/auth/confirm",
      exclude: ["/auth/*", "/"],
    },
    types: "./app/types/database.ts",
  },
  pinia: {
    storesDirs: ["./app/stores/**"],
  },
});
