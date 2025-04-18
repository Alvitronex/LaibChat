import 'package:flutter/material.dart';
import 'package:frontend/models/models.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/services.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String name;
  final String? imageUrl;

  const ChatDetailScreen({
    Key? key,
    required this.conversationId,
    required this.name,
    this.imageUrl,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isSending = false;
  bool _hasAttemptedLoad = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_hasAttemptedLoad && _retryCount >= 3) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Demasiados intentos. Intenta de nuevo más tarde.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasAttemptedLoad = true;
      _retryCount += 1;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!authService.authenticated) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No has iniciado sesión';
      });
      return;
    }

    try {
      final token = authService.token;
      if (token != null) {
        await chatService.fetchMessages(
            token, widget.conversationId, authService.user.id);
      }

      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });

      // Desplazar al final cuando se carguen los mensajes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar mensajes. Intenta nuevamente.';
      });
      print('Error detallado: $e');
    }
  }

  void _scrollToBottom() {
    try {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('Error al desplazar al final: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!authService.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has iniciado sesión')),
      );
      return;
    }

    // Crear mensaje local inmediatamente para mejor experiencia de usuario
    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final localMessage = Message(
      id: null,
      conversationId: widget.conversationId,
      userId: authService.user.id,
      user: null,
      text: message,
      isMe: true,
      read: false,
      time: formattedTime,
      createdAt: now,
      updatedAt: now,
    );

    // Añadir a la lista de mensajes localmente primero
    final existingMessages = chatService.getMessages(widget.conversationId);
    final updatedMessages = [...existingMessages, localMessage];

    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    // Actualizar mensajes localmente
    if (mounted) {
      // Desplazar al final inmediatamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    try {
      final token = authService.token;
      if (token != null) {
        await chatService.sendMessage(
            token, widget.conversationId, message, authService.user.id);
      }

      // El servicio ya ha actualizado la lista de mensajes
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red[100],
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => _resendMessage(message),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _resendMessage(String messageText) async {
    if (messageText.isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    try {
      final token = authService.token;
      if (token != null) {
        await chatService.sendMessage(
            token, widget.conversationId, messageText, authService.user.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar mensaje: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final messages = chatService.getMessages(widget.conversationId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? NetworkImage(widget.imageUrl!) as ImageProvider
                      : null,
              backgroundColor: Colors.purple[100],
              child: (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                  ? Text(
                      widget.name.isNotEmpty
                          ? widget.name[0].toUpperCase()
                          : "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _isLoading ? null : _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mensaje de error si existe
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    color: Colors.red[700],
                    onPressed: _loadMessages,
                  ),
                ],
              ),
            ),

          // Contenido principal
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando mensajes...'),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay mensajes aún',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sé el primero en enviar un mensaje',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final bool showTime = index == 0 ||
                                _shouldShowTime(messages[index],
                                    index > 0 ? messages[index - 1] : null);

                            return MessageBubble(
                              message: message,
                              showTime: showTime,
                            );
                          },
                        ),
                ),

          // Input para escribir mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    onTap: () {
                      // Desplazar al final cuando se selecciona el campo de texto
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTime(Message current, Message? previous) {
    if (previous == null) return true;

    // Si los mensajes son de diferentes usuarios, mostrar tiempo
    if (current.userId != previous.userId) return true;

    // Si hay más de 5 minutos entre mensajes, mostrar tiempo
    if (current.createdAt != null && previous.createdAt != null) {
      final difference = current.createdAt!.difference(previous.createdAt!);
      return difference.inMinutes > 5;
    }

    return false;
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTime;

  const MessageBubble({
    Key? key,
    required this.message,
    this.showTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.purple[100],
                child: Text(
                  message.user?.name.isNotEmpty == true
                      ? message.user!.name[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: message.isMe ? Colors.orange : Colors.grey[200],
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      message.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.amber[700],
                child: const Text(
                  "YO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
