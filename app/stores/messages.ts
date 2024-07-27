export type IMessage = {
  id: string;
  message: string;
  created_at: string;
  user_id: string;
  chat_id: string;
  user_metas?: {
    id: string;
    name: string;
  };
};

export const useMessagesStore = defineStore("messages", () => {
  const messages = ref<IMessage[]>([]);

  function addMessage(...newMessages: IMessage[]) {
    messages.value = [...newMessages, ...messages.value];
  }

  return { messages, addMessage };
});
