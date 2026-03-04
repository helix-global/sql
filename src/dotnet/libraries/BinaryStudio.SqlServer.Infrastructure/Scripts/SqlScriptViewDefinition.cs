using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlViewDefinition))]
    internal sealed class SqlScriptViewDefinition : SqlScriptCodeObject<SqlViewDefinition>
        {
        public Boolean HasCheckOption { get{return Source.HasCheckOption; }}

        #region ctor{IServiceProvider,SqlViewDefinition}
        public SqlScriptViewDefinition(IServiceProvider context,SqlViewDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }