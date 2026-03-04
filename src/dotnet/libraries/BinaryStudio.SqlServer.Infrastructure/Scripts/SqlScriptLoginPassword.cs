using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlLoginPassword))]
    internal sealed class SqlScriptLoginPassword : SqlScriptCodeObject<SqlLoginPassword>
        {
        public Boolean IsHashed {get{ return Source.IsHashed; }}
        public Boolean MustChange { get{ return Source.MustChange; }}

        #region ctor{IServiceProvider,SqlLoginPassword}
        public SqlScriptLoginPassword(IServiceProvider context,SqlLoginPassword source)
            : base(context,source)
            {
            }
        #endregion
        }
    }