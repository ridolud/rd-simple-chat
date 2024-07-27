export type IChat = {
  id: string;
  name: string;
  created_at: string;
  owner_id: string;
  last_message_created_at?: string;
  last_message_message?: string;
  last_message_user_name?: string;
  members: { user_id: string }[];
};

export const useChatsStore = defineStore("chats", () => {
  const chats = ref<IChat[]>([]);

  function addChat(channel: IChat) {
    chats.value = [...chats.value, channel];
  }

  function removeChat(id: string) {
    chats.value = chats.value.filter((channel) => channel.id != id);
  }

  return { chats, addChat, removeChat };
});
