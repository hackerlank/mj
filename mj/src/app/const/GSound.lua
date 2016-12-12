local GSound = class("GSound")
GSound.instance = nil

function GSound.getInstance()
	if not GSound.instance then
		GSound.instance = GSound.new()
	end
	return GSound.instance
end

--音乐管理
function GSound:setMusicVolume(val)
	AudioEngine.setMusicVolume(val)
end

--背景音乐特殊处理
--音量调节到最小以达到关闭的效果
function GSound:_colseMusicByVolume()
	AudioEngine.setMusicVolume(0)
    app:setMusicVolume(0)
end

--音量开到最大
function GSound:_resumeMusicByVolume()
	AudioEngine.setMusicVolume(1)
    app:setMusicVolume(1)
end

--播放音乐--默认都循环
function GSound:playMusic(file, arepeat)
	AudioEngine.playMusic(file, arepeat or true)
end

--暂停音乐--
function GSound:pauseMusic()
	self:_colseMusicByVolume()
end
-- 继续播放音乐  
function GSound:resumeMusic()
	self:_resumeMusicByVolume()
end
--停止音乐--
function GSound:stopMusics()
	AudioEngine.stopMusic()
end

--加减音乐音量--
function GSound:setMusicVolumes(_float)
	AudioEngine.setMusicVolume(AudioEngine.getMusicVolume() + _float)
end

--音效管理
--播放音效--
function GSound:playEffect(_file,_isCycle)
    return AudioEngine.playEffect(_file, _isCycle)
end

--根据音效id停止音效--
function GSound:stopEffects(_nSoundId)
	if _nSoundId then
		AudioEngine.stopEffect(_nSoundId)
	end
end

--暂停音效--
function GSound:pauseEeffects(_nSoundId)
	if _nSoundId then
		AudioEngine.pauseEffect(_nSoundId)
	end
end

--暂停所有音效--
function GSound:pauseAllEffects()
	AudioEngine.pauseAllEffects()
end

--恢复所有音效
function GSound:resumeAllEffects()
	AudioEngine.resumeAllEffects()
end

--加减音乐音量--
function GSound:setEffectVolumes(_float)
	AudioEngine.setEffectsVolume(AudioEngine.getEffectsVolume() + _float)
end

return GSound