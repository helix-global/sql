using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptVariableDeclaration<T> : SqlScriptCodeObject<T>
        where T : SqlVariableDeclaration
        {
        public String Name {get{ return Source.Name; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptVariableDeclaration(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }