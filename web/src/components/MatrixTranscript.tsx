/**
 * Matrix Transcript Component
 * Server-side rendered read-only chat transcript for sighting discussions
 */

import Link from 'next/link';

export interface MatrixMessage {
  id: string;
  sender: string;
  senderDisplayName: string;
  content: string;
  timestamp: Date;
  messageType: string;
}

export interface MatrixRoomInfo {
  id: string;
  name: string;
  memberCount: number;
  joinUrl: string;
  matrixToUrl: string;
}

interface MatrixTranscriptProps {
  messages: MatrixMessage[];
  roomInfo: MatrixRoomInfo | null;
  hasMatrixRoom: boolean;
  maxMessages?: number;
}

export default function MatrixTranscript({ 
  messages, 
  roomInfo, 
  hasMatrixRoom,
  maxMessages = 100 
}: MatrixTranscriptProps) {
  if (!hasMatrixRoom) {
    return (
      <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-text-primary flex items-center gap-2">
            💬 Discussion
          </h2>
          <span className="text-text-tertiary text-sm">Matrix chat unavailable</span>
        </div>
        
        <div className="bg-dark-background border border-dark-border rounded-lg p-6 text-center">
          <div className="text-4xl mb-4">💭</div>
          <p className="text-text-secondary mb-2">Real-time chat not configured</p>
          <p className="text-text-tertiary text-sm">
            This sighting doesn&apos;t have an active Matrix chat room yet.
          </p>
        </div>
      </section>
    );
  }

  const displayMessages = messages.slice(0, maxMessages);
  const totalMessages = messages.length;

  const getMessageIcon = (sender: string) => {
    if (sender.includes('verified') || sender.includes('observer')) {
      return (
        <div className="w-8 h-8 bg-semantic-info rounded-full flex items-center justify-center text-sm">
          ✓
        </div>
      );
    } else if (sender.includes('system') || sender.includes('bot')) {
      return (
        <div className="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center text-sm">
          🤖
        </div>
      );
    } else {
      return (
        <div className="w-8 h-8 bg-brand-primary rounded-full flex items-center justify-center text-sm">
          👤
        </div>
      );
    }
  };

  const getBadgeForUser = (sender: string) => {
    if (sender.includes('verified') || sender.includes('observer')) {
      return (
        <span className="text-semantic-info text-xs bg-semantic-info bg-opacity-20 px-2 py-0.5 rounded-full">
          Verified
        </span>
      );
    }
    return null;
  };

  const formatTimestamp = (timestamp: Date): string => {
    try {
      const now = new Date();
      const diffMs = now.getTime() - timestamp.getTime();
      const diffMinutes = Math.floor(diffMs / (1000 * 60));
      const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

      if (diffMinutes < 1) return 'just now';
      if (diffMinutes < 60) return `${diffMinutes}m ago`;
      if (diffHours < 24) return `${diffHours}h ago`;
      if (diffDays < 7) return `${diffDays}d ago`;
      
      return timestamp.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        ...(diffDays > 365 && { year: 'numeric' })
      });
    } catch {
      return 'recently';
    }
  };

  return (
    <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-semibold text-text-primary flex items-center gap-2">
          💬 Discussion
        </h2>
        <div className="flex items-center gap-3">
          {roomInfo && (
            <span className="text-text-tertiary text-sm">
              {roomInfo.memberCount} participant{roomInfo.memberCount !== 1 ? 's' : ''}
            </span>
          )}
          <div className="flex items-center gap-1">
            <div className="w-2 h-2 bg-semantic-success rounded-full animate-pulse"></div>
            <span className="text-semantic-success text-xs">Live</span>
          </div>
        </div>
      </div>
      
      {/* Chat Messages */}
      {displayMessages.length > 0 ? (
        <div className="space-y-4 mb-6">
          {displayMessages.map((message) => (
            <div key={message.id} className="bg-dark-background rounded-lg p-4">
              <div className="flex items-start gap-3">
                {getMessageIcon(message.sender)}
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1 flex-wrap">
                    <span className="text-text-primary font-medium text-sm">
                      {message.senderDisplayName}
                    </span>
                    {getBadgeForUser(message.sender)}
                    <span className="text-text-tertiary text-xs">
                      {formatTimestamp(message.timestamp)}
                    </span>
                  </div>
                  <div className="text-text-secondary text-sm leading-relaxed">
                    {message.content}
                  </div>
                </div>
              </div>
            </div>
          ))}
          
          {totalMessages > maxMessages && (
            <div className="text-center py-4">
              <p className="text-text-tertiary text-sm mb-2">
                Showing last {maxMessages} of {totalMessages} messages
              </p>
              <button className="text-brand-primary hover:text-brand-primary-light text-sm">
                View Full History →
              </button>
            </div>
          )}
        </div>
      ) : (
        <div className="bg-dark-background rounded-lg p-6 text-center mb-6">
          <div className="text-4xl mb-4">👋</div>
          <p className="text-text-secondary mb-2">No messages yet</p>
          <p className="text-text-tertiary text-sm">
            Be the first to share your observations about this sighting.
          </p>
        </div>
      )}
      
      {/* Matrix Room Actions */}
      <div className="border-t border-dark-border pt-4">
        <div className="flex items-center justify-between mb-3">
          <p className="text-text-secondary text-sm">
            Real-time encrypted discussion via Matrix protocol
          </p>
          {roomInfo && (
            <Link 
              href={roomInfo.matrixToUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-brand-primary hover:text-brand-primary-light text-sm"
            >
              View Full Chat →
            </Link>
          )}
        </div>
        
        <div className="bg-dark-background border border-dark-border rounded-lg p-3">
          <p className="text-text-tertiary text-xs mb-2">
            Join the discussion (Matrix account required)
          </p>
          <div className="flex gap-2">
            {roomInfo && (
              <>
                <Link
                  href={roomInfo.joinUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 bg-brand-primary text-text-inverse py-2 px-4 rounded text-sm font-medium hover:bg-brand-primary-dark transition-colors text-center"
                >
                  Join Chat Room
                </Link>
                <button
                  onClick={() => navigator.clipboard?.writeText(roomInfo.id)}
                  className="bg-dark-surface border border-dark-border text-text-primary py-2 px-4 rounded text-sm hover:bg-dark-border-light transition-colors"
                >
                  Copy Room ID
                </button>
              </>
            )}
          </div>
          
          {roomInfo && (
            <div className="mt-3 pt-3 border-t border-dark-border">
              <div className="grid grid-cols-2 gap-4 text-xs text-text-tertiary">
                <div>
                  <p className="font-medium mb-1">Matrix Room:</p>
                  <p className="font-mono break-all">{roomInfo.id}</p>
                </div>
                <div>
                  <p className="font-medium mb-1">Direct Link:</p>
                  <Link 
                    href={roomInfo.matrixToUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-brand-primary hover:text-brand-primary-light break-all"
                  >
                    matrix.to link
                  </Link>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}