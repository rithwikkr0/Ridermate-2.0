import React from 'react';
import { LucideIcon } from 'lucide-react';

interface FeatureCardProps {
  icon: LucideIcon;
  badge?: string;
  title: string;
  description: string;
  benefits: string[];
  gradient?: string;
}

export const FeatureCard: React.FC<FeatureCardProps> = ({
  icon: Icon,
  badge,
  title,
  description,
  benefits,
  gradient = 'from-circuitOrange/20 to-transparent'
}) => {
  return (
    <div className="glass-panel glass-panel-hover rounded-2xl p-6 sm:p-8 flex flex-col justify-between relative overflow-hidden group">
      {/* Glow highlight behind icon */}
      <div className={`absolute -top-12 -right-12 w-36 h-36 bg-gradient-to-br ${gradient} rounded-full blur-2xl group-hover:scale-125 transition-transform duration-500 pointer-events-none`} />

      <div>
        <div className="flex items-center justify-between mb-5">
          <div className="w-12 h-12 rounded-xl bg-circuitOrange/10 border border-circuitOrange/30 flex items-center justify-center text-circuitOrange group-hover:bg-circuitOrange group-hover:text-white transition-colors duration-300 shadow-md shadow-circuitOrange/10">
            <Icon className="w-6 h-6" />
          </div>
          {badge && (
            <span className="px-2.5 py-0.5 rounded-full text-[11px] font-mono font-semibold bg-white/5 border border-white/10 text-circuitOrange">
              {badge}
            </span>
          )}
        </div>

        <h3 className="text-xl font-bold text-white mb-2 group-hover:text-circuitOrange transition-colors">
          {title}
        </h3>
        
        <p className="text-sm text-onSurfaceVariant leading-relaxed mb-6">
          {description}
        </p>
      </div>

      <div className="pt-4 border-t border-white/5 space-y-2">
        <span className="text-[11px] font-mono font-bold uppercase tracking-wider text-onSurfaceVariant/70 block">
          Key Benefits
        </span>
        <ul className="space-y-1.5">
          {benefits.map((benefit, idx) => (
            <li key={idx} className="flex items-center gap-2 text-xs text-onSurface">
              <span className="w-1.5 h-1.5 rounded-full bg-circuitOrange" />
              <span>{benefit}</span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};
