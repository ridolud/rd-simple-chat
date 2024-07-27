<script setup lang="ts">
import { ChatNewChannelModal } from "#components";

// New Chat Modal
const newChannelModal = useModal();
function handleOpenNewChannelModal() {
  newChannelModal.open(ChatNewChannelModal, {
    onClose() {
      newChannelModal.close();
    },
  });
}

// Logout
const { auth } = useSupabaseClient();
const loading = useLoadingIndicator();
const handleLogout = async () => {
  loading.start();
  await auth.signOut();
  loading.finish();

  useRouter().replace("/auth/login");
};

const menus = [
  [
    {
      label: "New Chat",
      icon: "i-heroicons-plus",
      click: () => handleOpenNewChannelModal(),
    },
  ],
  [
    {
      label: "Logout",
      icon: "i-heroicons-arrow-left-on-rectangle",
      click: () => handleLogout(),
    },
  ],
];
</script>

<template>
  <UDropdown :items="menus" :popper="{ placement: 'bottom-end' }">
    <UButton
      size="xl"
      color="gray"
      variant="link"
      icon="i-heroicons-ellipsis-vertical"
    ></UButton>
    <template #item="{ item }">
      <span class="truncate">{{ item.label }}</span>
      <UIcon :name="item.icon" class="flex-shrink-0 h-4 w-4 ms-auto" />
    </template>
  </UDropdown>
</template>
