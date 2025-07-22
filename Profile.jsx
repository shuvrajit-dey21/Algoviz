import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import './Profile.css';

const Profile = () => {
  const [isLoaded, setIsLoaded] = useState(false);
  
  // Sample user data - replace with actual data in your implementation
  const userData = {
    name: "Alex Johnson",
    title: "Full Stack Developer",
    location: "San Francisco, CA",
    bio: "Passionate about creating seamless user experiences and solving complex problems through clean code.",
    stats: [
      { label: "Projects", value: 24 },
      { label: "Followers", value: 568 },
      { label: "Following", value: 327 },
    ],
    skills: ["JavaScript", "React", "Node.js", "Python", "UI/UX", "MongoDB"]
  };
  
  useEffect(() => {
    setIsLoaded(true);
  }, []);
  
  return (
    <div className="profile-container">
      <motion.div 
        className="profile-card"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: isLoaded ? 1 : 0, y: isLoaded ? 0 : 50 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
      >
        <div className="profile-header">
          <motion.div 
            className="profile-avatar-container"
            initial={{ scale: 0 }}
            animate={{ scale: isLoaded ? 1 : 0 }}
            transition={{ delay: 0.3, duration: 0.6, type: "spring" }}
          >
            <div className="profile-avatar">
              <span>{userData.name.charAt(0)}</span>
            </div>
          </motion.div>
          
          <motion.div 
            className="profile-info"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: isLoaded ? 1 : 0, x: isLoaded ? 0 : 20 }}
            transition={{ delay: 0.5, duration: 0.6 }}
          >
            <h1>{userData.name}</h1>
            <h2>{userData.title}</h2>
            <p className="location">{userData.location}</p>
          </motion.div>
        </div>
        
        <motion.div 
          className="profile-bio"
          initial={{ opacity: 0 }}
          animate={{ opacity: isLoaded ? 1 : 0 }}
          transition={{ delay: 0.7, duration: 0.6 }}
        >
          <p>{userData.bio}</p>
        </motion.div>
        
        <motion.div 
          className="profile-stats"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: isLoaded ? 1 : 0, y: isLoaded ? 0 : 30 }}
          transition={{ delay: 0.9, duration: 0.6 }}
        >
          {userData.stats.map((stat, index) => (
            <motion.div 
              key={index} 
              className="stat-item"
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: isLoaded ? 1 : 0.8, opacity: isLoaded ? 1 : 0 }}
              transition={{ delay: 1 + (index * 0.1), duration: 0.4 }}
            >
              <span className="stat-value">{stat.value}</span>
              <span className="stat-label">{stat.label}</span>
            </motion.div>
          ))}
        </motion.div>
        
        <motion.div 
          className="profile-skills"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: isLoaded ? 1 : 0, y: isLoaded ? 0 : 30 }}
          transition={{ delay: 1.2, duration: 0.6 }}
        >
          <h3>Skills</h3>
          <div className="skills-container">
            {userData.skills.map((skill, index) => (
              <motion.span 
                key={index} 
                className="skill-tag"
                initial={{ scale: 0, opacity: 0 }}
                animate={{ scale: isLoaded ? 1 : 0, opacity: isLoaded ? 1 : 0 }}
                transition={{ delay: 1.4 + (index * 0.1), duration: 0.4, type: "spring" }}
              >
                {skill}
              </motion.span>
            ))}
          </div>
        </motion.div>
        
        <motion.button 
          className="edit-profile-button"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: isLoaded ? 1 : 0, y: isLoaded ? 0 : 20 }}
          transition={{ delay: 1.8, duration: 0.4 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Edit Profile
        </motion.button>
      </motion.div>
      
      <motion.div 
        className="floating-action-button"
        initial={{ scale: 0 }}
        animate={{ scale: isLoaded ? 1 : 0 }}
        transition={{ delay: 2, duration: 0.5, type: "spring" }}
        whileHover={{ scale: 1.1, rotate: 90 }}
        whileTap={{ scale: 0.9 }}
      >
        <span>+</span>
      </motion.div>
    </div>
  );
};

export default Profile; 