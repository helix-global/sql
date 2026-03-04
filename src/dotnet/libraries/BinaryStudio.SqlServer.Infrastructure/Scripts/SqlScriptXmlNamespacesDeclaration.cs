using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptXmlNamespacesDeclaration : SqlScriptCodeObject<SqlXmlNamespacesDeclaration>
        {
        #region ctor{IServiceProvider,SqlXmlNamespacesDeclaration}
        public SqlScriptXmlNamespacesDeclaration(IServiceProvider context,SqlXmlNamespacesDeclaration source)
            : base(context,source)
            {
            }
        #endregion
        }
    }