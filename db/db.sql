/*
    数据库

    上次修改时间：20210602
*/
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- ----------------------------
-- Table structure for pan_user
-- ----------------------------
DROP TABLE IF EXISTS `pan_user`;
CREATE TABLE `pan_user`  (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role` int(11) NOT NULL COMMENT '1    -  普通用户；2    -  管理员',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`user_name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pan_user
-- ----------------------------
INSERT INTO `pan_user` VALUES (7, 'eva', '123456', 1);
INSERT INTO `pan_user` VALUES (8, 'faye', '123123', 2);
INSERT INTO `pan_user` VALUES (16, 'wang', '7w5NCeWa9TvK6aN', 1);


-- ----------------------------
-- Table structure for board
-- ----------------------------
DROP TABLE IF EXISTS `board`;
CREATE TABLE `board`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` json NOT NULL,
  `expired_date` datetime(0) NOT NULL,
  `enabled` int(5) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of board
-- ----------------------------
INSERT INTO `board` VALUES (1, '{\"title\": \"消息\", \"content\": \"欢迎您使用本网盘。\"}', '2021-05-27 13:25:04', 0);
INSERT INTO `board` VALUES (6, '{\"title\": \"消息\", \"content\": \"公告\"}', '2021-04-07 20:27:45', 0);
INSERT INTO `board` VALUES (7, '{\"title\": \"消息\", \"content\": \"欢迎使用！😋\"}', '2021-05-08 01:06:32', 1);


-- ----------------------------
-- Table structure for jsont2
-- ----------------------------
DROP TABLE IF EXISTS `jsont2`;
CREATE TABLE `jsont2`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pathid` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `value` json NULL,
  `path` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci GENERATED ALWAYS AS (json_unquote(json_extract(`value`,_utf8mb3'$.path'))) VIRTUAL NOT NULL,
  `user_id` int(11) NOT NULL,
  `extra_info` json NULL,
  `fullpath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci GENERATED ALWAYS AS (concat(cast(`user_id` as char charset utf8mb4),_utf8mb4':',json_unquote(json_extract(`value`,_utf8mb3'$.path')),json_unquote(json_extract(`value`,_utf8mb3'$.name')))) VIRTUAL NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `fullpath_index`(`fullpath`) USING BTREE,
  INDEX `path_index`(`path`) USING BTREE,
  INDEX `fk_userid`(`user_id`) USING BTREE,
  CONSTRAINT `fk_userid` FOREIGN KEY (`user_id`) REFERENCES `pan_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsont2
-- ----------------------------
INSERT INTO `jsont2`( `pathid`, `value`,  `user_id`, `extra_info`) VALUES ( 'ok', '{\"name\": \"Folder1\", \"path\": \"/\", \"size\": 0, \"type\": \"d\", \"objname\": \"\"}',  16, NULL);
INSERT INTO `jsont2`( `pathid`, `value`,  `user_id`, `extra_info`) VALUES ( 'ok', '{\"name\": \"Folder1\", \"path\": \"/\", \"size\": 0, \"type\": \"d\", \"objname\": \"\"}',  7, NULL);


-- ----------------------------
-- Table structure for share_files1
-- ----------------------------
DROP TABLE IF EXISTS `share_files1`;
CREATE TABLE `share_files1`  (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `short_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `expired_date` datetime(0) NOT NULL,
  `extra_info` json NULL,
  `visited_count` int(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`short_url`) USING BTREE,
  UNIQUE INDEX `key`(`key`) USING BTREE,
  INDEX `fk_userid_sharefiles1`(`user_id`) USING BTREE,
  CONSTRAINT `fk_userid_sharefiles1` FOREIGN KEY (`user_id`) REFERENCES `pan_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for user_storage
-- ----------------------------
DROP TABLE IF EXISTS `user_storage`;
CREATE TABLE `user_storage`  (
  `user_id` int(11) NOT NULL,
  `max_size` int(21) NOT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  CONSTRAINT `fk_userid_userstorage` FOREIGN KEY (`user_id`) REFERENCES `pan_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_storage
-- ----------------------------
INSERT INTO `user_storage` VALUES (7, 734003200);
INSERT INTO `user_storage` VALUES (16, 419430400);


SET FOREIGN_KEY_CHECKS = 1;
-- 热门共享文件视图
drop view if EXISTS `hot_share_view`;
create view `hot_share_view` as select `share_files1`.`short_url` AS `short_url`,`share_files1`.`expired_date` AS `expired_date`,`share_files1`.`user_id` AS `user_id`,`jsont2`.`id` AS `fileid`,`jsont2`.`value` AS `value`,`share_files1`.`visited_count` AS `visited_count` from (`share_files1` left join `jsont2` on((json_unquote(json_extract(`share_files1`.`extra_info`,'$.id')) = `jsont2`.`id`))) where (now() < `share_files1`.`expired_date`) order by `share_files1`.`visited_count` desc;
-- 共享文件详细信息视图
drop view if EXISTS `share_files_view`;
create view `share_files_view` as select `share_files1`.`short_url` AS `short_url`,`share_files1`.`expired_date` AS `expired_date`,`share_files1`.`user_id` AS `user_id`,`jsont2`.`id` AS `fileid`,`jsont2`.`value` AS `value` from (`share_files1` left join `jsont2` on((json_unquote(json_extract(`share_files1`.`extra_info`,'$.id')) = `jsont2`.`id`)));

-- 存储过程
drop PROCEDURE  if EXISTS `dir2`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dir2`(IN `p` varchar(1000))
BEGIN
    SELECT * FROM `jsont2` WHERE path REGEXP  CONCAT('^',`p`,'[^/]*$') and pathid!='' ORDER BY JSON_EXTRACT(value,'$.type') ASC ,JSON_EXTRACT(value, '$.name') ASC;
END;

drop PROCEDURE  if EXISTS `dir3`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dir3`(IN `p` varchar(1000),IN inuser_id int)
BEGIN
    SELECT * FROM `jsont2` WHERE path REGEXP  CONCAT('^',`p`,'[^/]*$') and user_id =inuser_id and pathid!='' ORDER BY JSON_EXTRACT(value,'$.type') ASC ,JSON_EXTRACT(value, '$.name') ASC;
END;

drop PROCEDURE  if EXISTS `mkdir1`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mkdir1`( IN `fid` INT, IN `name` VARCHAR ( 1000 ), IN `user_id` INT )
BEGIN
	DECLARE
		ok INT DEFAULT - 1;
	DECLARE
		mes VARCHAR ( 255 ) DEFAULT 'ok';
	DECLARE
		newfid INT DEFAULT - 1;
	IF `fid` = 0 THEN
		SET @fvalue = '{}';
		SET @folder = '/';
	ELSE
		SET @fvalue := ( SELECT `value` FROM jsont2 WHERE id = `fid` );
		SET @folder = CONCAT( JSON_UNQUOTE( JSON_EXTRACT( @fvalue, '$.path' ) ), CONVERT ( `fid`, CHAR ), '/' );
	end IF;
	

	IF
		ISNULL( @fvalue ) THEN	
			SET ok = 1001,
			mes = 'the parent folder not exist.';
		ELSE 
		
		SET @count := (
			SELECT
				COUNT( * ) 
			FROM
				jsont2 
			WHERE
				JSON_EXTRACT( `value`, '$.type' ) = 'd' 
				AND path = @folder 
				AND JSON_EXTRACT( `value`, '$.name' ) = `name` 
				AND jsont2.user_id = `user_id`
			);

		IF
			@count = 0 THEN

			INSERT INTO jsont2 (pathid, VALUE, user_id )
			VALUES
				('ok', JSON_REPLACE( '{"name": "a", "path": "/","size":0, "type": "d", "objname": ""}', '$.name', `name`, '$.path', @folder ), `user_id` );
				
			set @newfid =(select LAST_INSERT_ID());
			
		
			SET ok = 1;
			
			ELSE 
				SET ok = 1002,
				mes = 'the path is exist.';
			
		END IF;
		
	END IF;
	SELECT
		ok,
		mes,
		@newfid;#select CONCAT(MD5(CONCAT(`folder`,`name`)),'-',CONVERT( `user_id`, char)) a;

END;

drop PROCEDURE  if EXISTS `rm1`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `rm1`(IN `path` varchar(1000), IN `nameid` varchar(1000),in inuser_id int)
BEGIN
	
	START TRANSACTION;

	DELETE from jsont2 where JSON_UNQUOTE(JSON_EXTRACT(value, '$.path')) like CONCAT(`path`,`nameid`,'/%') and user_id = inuser_id;
	DELETE FROM jsont2 where id =	CONVERT(`nameid` ,SIGNED) and user_id = inuser_id;
	
	COMMIT;
END;

drop PROCEDURE  if EXISTS `copyfiles2`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `copyfiles2`( IN `p` varchar(1000),IN `dest` varchar(1000) ,IN `user_id` int)
start_label:BEGIN
	DECLARE
		ext MEDIUMTEXT;
		
	DECLARE
		done INT DEFAULT 0;
	DECLARE
		duperr INT DEFAULT 0;
	DECLARE
		cur0 CURSOR FOR SELECT
		extra_info 
	FROM
		`jsont2` 
	WHERE
		pathid = @ident 
		AND JSON_EXTRACT( VALUE, '$.type' ) = 'd';
		
	DECLARE
		CONTINUE HANDLER FOR NOT found 
		SET done = 1;
	
	   DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'  
     SET duperr = 1;  
	
			SET @ident = unix_timestamp( );

	if p = '/' then
	
	
			select 5 as duperr;

			leave start_label;
			
	end if;

	
	INSERT INTO `jsont2` ( pathid, `value`, user_id, extra_info ) SELECT
			@ident AS pathid,
			JSON_REPLACE(value, '$.path', REPLACE (path,		p,	dest ))  as `value`,
			user_id,
			JSON_OBJECT( 'sid', id ) AS extra_info 
		FROM
			`jsont2` 
		WHERE
			path REGEXP  CONCAT('^',p,'[^/]*') 
			and jsont2.user_id = user_id;
	-- 	LEAVE start_label;
		-- SET @flist = ( SELECT extra_info FROM `jsont2` WHERE pathid = @ident AND JSON_EXTRACT( VALUE, '$.type' ) = 'd' );
	OPEN cur0;
	www :
	LOOP
			FETCH cur0 INTO ext;
		IF
			done = 1 THEN
			
				LEAVE www;
			
		END IF;
		set @sid = JSON_UNQUOTE( JSON_EXTRACT( ext, '$.sid' ) );
		SET @idtext = CONCAT( '/', @sid, '/' );
		set @destid = (select id from jsont2 where JSON_UNQUOTE(JSON_EXTRACT(extra_info, '$.sid')) = @sid and pathid = @ident );

		-- SELECT @sid,@idtext, @destid;
		UPDATE `jsont2` 
		SET `value` = JSON_REPLACE(
			`value`,
			'$.path',
			REPLACE (
				path,
				@idtext,
				CONCAT( '/', @destid, '/' ) 
			)  
		) 
		WHERE
			(pathid = convert( @ident,char) );
			-- AND (JSON_EXTRACT( `VALUE`, '$.type' ) = 'n');
		
		IF
			duperr = 1 THEN
			select 'dup' as mes;
			delete from jsont2 where (pathid = convert( @ident,char) );
				LEAVE www;
			
		END IF;
		
-- select 
-- JSON_REPLACE(
-- 			`value`,
-- 			'$.path',
-- 			REPLACE (
-- 				path,
-- 				@idtext,
-- 				CONCAT( '/', @destid, '/' ) 
-- 			) 
-- 		) as `vv`
-- 		from jsont2
-- 		WHERE
-- 			pathid = @ident 
-- 			AND JSON_EXTRACT( VALUE, '$.type' ) = 'n';
-- 			
	END LOOP;
	CLOSE cur0;
	select duperr;

END;

drop PROCEDURE  if EXISTS `mv2`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mv2`( IN `p` VARCHAR ( 1000 ), IN `dest` VARCHAR ( 1000 ),IN `user_id` int )
start_label:BEGIN
	DECLARE
		duperr INT DEFAULT 0;
	DECLARE
		CONTINUE HANDLER FOR SQLSTATE '23000' 
		SET duperr = 1;
	
	if p = '/' then
	
	
			select 5 as duperr;

			leave start_label;
			
	end if;
	
	
	SET @ident = unix_timestamp( );
	update `jsont2`
	set `value` =
	JSON_REPLACE( VALUE, '$.path', REPLACE ( path, p, dest ) )
	WHERE
		path REGEXP CONCAT( '^', p, '[^/]*' )
		and jsont2.user_id = user_id;
	
	SELECT
		duperr;

END;

drop PROCEDURE  if EXISTS `rm1`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `rm1`(IN `path` varchar(1000), IN `nameid` varchar(1000),in inuser_id int)
BEGIN
	
	
	START TRANSACTION;

	DELETE from jsont2 where JSON_UNQUOTE(JSON_EXTRACT(value, '$.path')) like CONCAT(`path`,`nameid`,'/%') and user_id = inuser_id;
	DELETE FROM jsont2 where id =	CONVERT(`nameid` ,SIGNED) and user_id = inuser_id;
	
	COMMIT;
END;

