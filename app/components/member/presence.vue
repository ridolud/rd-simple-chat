<script setup lang="ts">
import type { Database } from "~/types/database";

const props = defineProps<{ members: { user_id: string }[] }>();

const onlineMembers = useState<string[]>("online-members", () => []);
const onlineMembersOnCurrentChat = computed(
  () =>
    props.members.filter((member) =>
      onlineMembers.value.includes(member.user_id)
    ).length
);
</script>

<template>
  <div v-if="onlineMembersOnCurrentChat" className="flex items-center gap-1">
    <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse"></div>
    <h1 className="text-xs text-gray-400">
      {{ onlineMembersOnCurrentChat }} onlines
    </h1>
  </div>
</template>
