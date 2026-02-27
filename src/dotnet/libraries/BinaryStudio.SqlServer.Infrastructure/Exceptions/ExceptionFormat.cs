using DocumentFormat.OpenXml.Drawing.Charts;
using DocumentFormat.OpenXml.Office2010.CustomUI;
using DocumentFormat.OpenXml.Office2016.Drawing.ChartDrawing;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class ExceptionFormat
        {
        #region M:ToString(Exception):String
        public String ToString(Exception e) {
            var r = new StringBuilder();
            WriteTo(e,r);
            return r.ToString();
            }
        #endregion
        #region M:ToString(Exception,StringBuilder):StringBuilder
        private StringBuilder WriteTo(Exception source,StringBuilder target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            using (var writer = new StringWriter(target)) {
                WriteTo(source,writer);
                }
            return target;
            }
        #endregion
        #region M:WriteTo(Exception,TextWriter):TextWriter
        protected TextWriter WriteTo(Exception source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            var order = new OrderSequence();
            var block = new BlockG(order,source,true);
            block.WriteTo(target);
            return target;
            }
        #endregion
        #region M:Format(MethodInfo):String
        public static String Format(MethodBase mi) {
            var r = new StringBuilder();
            r.Append($"{(mi.ReflectedType??mi.DeclaringType).Namespace}.");
            r.Append(Format(mi.ReflectedType??mi.DeclaringType));
            r.Append(".");
            r.Append(mi.Name);
            if (mi.IsGenericMethodDefinition) {
                var GenericArguments = mi.GetGenericArguments();
                r.Append("<");
                r.Append(String.Join(",",GenericArguments.Select(Format)));
                r.Append(">");
                }
            r.Append("(");
            r.Append(String.Join(",",mi.GetParameters().Select(Format)));
            r.Append(")");
            return r.ToString();
            }
        #endregion
        #region M:Format(ParameterInfo):String
        /// <summary>Generates a simplified, human-readable string representation of the specified parameter information.</summary>
        /// <param name="source">The parameter information to format.</param>
        /// <returns>A string that represents the formatted parameter information.</returns>
        private static String Format(ParameterInfo source) {
            var r = new StringBuilder();
            if (source.IsOut)
                {
                r.Append("{out}");
                }
            else if (source.ParameterType.IsByRef)
                {
                r.Append("{ref}");
                }
            else if (source.CustomAttributes.Any(i=>i.AttributeType == typeof(ParamArrayAttribute)))
                {
                r.Append("{params}");
                }
            r.Append(Format(source.ParameterType));
            if (r[r.Length-1] == '&') {
                r.Remove(r.Length-1,1);
                }
            return r.ToString();
            }
        #endregion
        #region M:Format(Type):String
        /// <summary>Generates a simplified, human-readable string representation of the specified type, including generic and nullable type formatting.</summary>
        /// <param name="source">The type to format. This can be a generic, nullable, or reference type.</param>
        /// <returns>A string that represents the formatted type name, including generic arguments and nullable notation where applicable.</returns>
        /// <remarks>This method formats generic types using angle brackets and appends a question mark for nullable types. Reference types are dereferenced before formatting. The output is intended for display or diagnostic purposes and may differ from the full type name or assembly-qualified name.</remarks>
        private static String Format(Type source) {
            if (source.IsByRef) { return Format(source.GetElementType()); }
            if (!source.IsConstructedGenericType && !source.IsGenericTypeDefinition) { return source.Name; }
            var r = new StringBuilder();
            var type = source.GetGenericTypeDefinition();
            if (type == typeof(Nullable<>)) {
                r.Append(Format(source.GetGenericArguments()[0]));
                r.Append("?");
                return r.ToString();
                }
            var match = Regex.Match(source.Name,@".+`(\d+)$");
            if (match.Success) {
                r.Append(source.Name.Substring(0,source.Name.Length-1-match.Groups[1].Value.Length));
                r.Append("<");
                if (source.IsGenericTypeDefinition && source is TypeInfo typeinfo)
                    {
                    r.Append(String.Join(",",typeinfo.GenericTypeParameters.Select(Format)));
                    }
                else
                    {
                    r.Append(String.Join(",",source.GetGenericArguments().Select(Format)));
                    }
                r.Append(">");
                return r.ToString();
                }
            return source.Name;
            }
        #endregion
        #region M:FormatStackFrame(StackFrame):String
        private static String FormatStackFrame(StackFrame frame) {
            if (frame == null) { throw new ArgumentNullException(nameof(frame)); }
            var r = new StringBuilder();
            var mi = frame.GetMethod();
            if (mi != null)
                {
                r.Append(Format(mi));
                }
            else
                {
                r.Append("<unknown method>");
                }
            var file = frame.GetFileName();
            if (!String.IsNullOrEmpty(file)) {
                r.Append($" in {PathContext.GetFileName(file)}:line {frame.GetFileLineNumber()}");
                }
            return r.ToString();
            }
        #endregion
        #region M:Serialize(IEnumerable):IEnumerable<String>
        private static IEnumerable<String> Serialize(IEnumerable source) {
            var values = source.OfType<Object>().ToArray();
            if (values.Length == 1) {
                foreach (var i in Serialize(values[0])) {
                    yield return i;
                    }
                yield break;
                }
            }
        #endregion
        #region M:Serialize(Object):IEnumerable<String>
        private static IEnumerable<String> Serialize(Object source) {
                 if ((source == null) || (source is DBNull)) { yield return "null"; }
            else if (source is IExceptionSerializable e) {
                foreach (var i in Serialize(e)) {
                    yield return i;
                    }
                }
            else
                {
                var type = source.GetType();
                if ((type == typeof(Byte))  || (type == typeof(SByte))  || (type == typeof(Decimal)) ||
                    (type == typeof(Int16)) || (type == typeof(UInt16)) || (type == typeof(Double))  ||
                    (type == typeof(Int32)) || (type == typeof(UInt32)) || (type == typeof(Single))  ||
                    (type == typeof(Int64)) || (type == typeof(UInt64)))
                    {
                    yield return source.ToString();
                    }
                else if (type == typeof(String)) { yield return $@"""{source}"""; }
                else if (source is IEnumerable values) {
                    foreach (var i in Serialize(values)) {
                        yield return i;
                        }
                    }
                else
                    {
                    yield return $@"""{source}""";
                    }
                }
            }
        #endregion

        private class OrderSequence
            {
            public Int32 Order { get;private set; }
            public Int32 NextOrder()
                {
                return ++Order;
                }

            public override String ToString()
                {
                return Order.ToString();
                }
            }

        private class BlockG
            {
            public Exception Source { get; }
            public Int32 Order { get; }
            public IList<BlockG> InnerE { get; } = new List<BlockG>();
            public IList<BlockG> InnerA { get; } = new List<BlockG>();
            private readonly OrderSequence OrderSequence;

            public BlockG(OrderSequence order,Exception source,Boolean BuildChain) {
                OrderSequence = order;
                Source = source;
                if (BuildChain) {
                    var e = source;
                    while (e != null) {
                        InnerE.Add(new BlockG(order,e,false));
                        if (e is AggregateException aggregate) {
                            break;
                            }
                        e = e.InnerException;
                        }
                    }
                else
                    {
                    Order = order.NextOrder();
                    if (source is AggregateException aggregate) {
                        foreach (var e in aggregate.InnerExceptions) {
                            InnerA.Add(new BlockG(order,e,true));
                            }
                        }
                    }
                }

            public BlockG()
                {
                }

            #region M:WriteTo(TextWriter):Void
            public void WriteTo(TextWriter target) {
                if (target == null) { throw new ArgumentNullException(nameof(target)); }
                WriteLevel0(target,String.Empty);
                }
            #endregion
            #region M:WriteToLevel1(TextWriter,String)
            private void WriteLevel0(TextWriter target,String left) {
                if (target == null) { throw new ArgumentNullException(nameof(target)); }
                var offset = (OrderSequence.Order - 1).ToString().Length;
                foreach (var e in InnerE) {
                    target.WriteLine($"{left}{{{e.Order.ToString().PadLeft(offset, '0')}}} {{{e.Source.GetType().FullName}}}:{{{e.Source.HResult.ToString("x8")}}}: {e.Source.Message}");
                    }
                if (InnerE.Any(i=>HasStackTrace(i.Source))) {
                    target.WriteLine($"{left}{new String(' ',offset)} # Exception stack trace:");
                    foreach (var e in InnerE.Reverse()) {
                        if (HasStackTrace(e.Source)) {
                            var stacktr = new StackTrace(e.Source,true);
                            var j = 0;
                            foreach (var s in stacktr.GetFrames()) {
                                if (j == 0)
                                    {
                                    target.WriteLine($"{left}{{{e.Order.ToString().PadLeft(offset, '0')}}} at {FormatStackFrame(s)}");
                                    }
                                else
                                    {
                                    target.WriteLine($"{left}{new String(' ',offset)}   at {FormatStackFrame(s)}");
                                    }
                                j++;
                                }
                            }
                        if (HasData(e.Source)) {
                            target.WriteLine($"{left}{new String(' ',offset)} # Exception data:");
                            foreach (var key in e.Source.Data.Keys) {
                                target.Write($@"{left}{new String(' ',offset)} ""{key}"":");
                                var j = 0;
                                foreach (var line in Serialize(e.Source.Data[key])) {
                                    if (j > 0) { target.Write($"{left}{new String(' ',offset)}          "); }
                                    target.WriteLine(line);
                                    j++;
                                    }
                                }
                            }
                        if (e.InnerA.Count > 0) {
                            target.WriteLine($"{left}{new String(' ',offset)} # Inner exceptions {{Count={e.InnerA.Count}}}:");
                            var j = 1;
                            foreach (var a in e.InnerA) {
                                target.WriteLine($"{left}{new String(' ',offset)}   # Inner exception {{Order={j}}}:");
                                a.WriteLevel0(target,$"{left}{new String(' ',offset)}    ");
                                j++;
                                }
                            }
                        }
                    }
                }
            #endregion
            #region M:HasStackTrace(Exception):Boolean
            private static Boolean HasStackTrace(Exception e) {
                if (e == null) { throw new ArgumentNullException(nameof(e)); }
                return !String.IsNullOrEmpty(e.StackTrace);
                }
            #endregion
            #region M:HasData(Exception):Boolean
            private static Boolean HasData(Exception e) {
                if (e == null) { throw new ArgumentNullException(nameof(e)); }
                return e.Data.Count > 0;
                }
            #endregion
            }
        }
    }
