using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlParameterDeclaration))]
    internal sealed class SqlScriptParameterDeclaration : SqlScriptVariableDeclaration<SqlParameterDeclaration>
        {
        public Boolean IsOutput { get { return Source.IsOutput; }}
        public Boolean IsReadOnly { get { return Source.IsReadOnly; }}

        #region ctor{IServiceProvider,SqlParameterDeclaration}
        public SqlScriptParameterDeclaration(IServiceProvider context,SqlParameterDeclaration source)
            : base(context,source)
            {
            }
        #endregion
        }
    }